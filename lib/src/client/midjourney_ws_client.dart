import 'dart:async';
import 'dart:convert';

import 'package:midjourney_api_dart/api.dart';
import 'package:midjourney_api_dart/src/model/midjourney_ws_event.dart';
import 'package:web_socket/web_socket.dart';

/// Implementation of the Midjourney WebSocket client.
class MidjourneyWSClientImpl implements MidjourneyWSClient {
  /// Constructor for the MidjourneyWSClientImpl.
  ///
  /// [config] is the configuration for the Midjourney API.
  /// [eventFactories] is a list of factories to create MidjourneyWSEvents.
  MidjourneyWSClientImpl({
    required MidjourneyConfig config,
    required List<MidjourneyWSEventFactory> eventFactories,
  })  : _config = config,
        _eventFactories = eventFactories;

  final MidjourneyConfig _config;
  final List<MidjourneyWSEventFactory> _eventFactories;

  WebSocket? _webSocket;
  final _eventsController = StreamController<MidjourneyWSEvent>.broadcast();

  @override
  Future<void> connect({String version = '4'}) async {
    final wsUri = Uri.parse('${_config.wsUrl}?token=${_config.wsUserToken}&v=$version');
    _webSocket = await WebSocket.connect(wsUri);
    _webSocket!.events.listen(_handleWebSocketEvent);
  }

  @override
  Future<void> disconnect() async {
    await _webSocket?.close();
    await _eventsController.close();
  }

  @override
  Stream<MidjourneyWSEvent> get events => _eventsController.stream;

  /// Handles incoming WebSocket events and converts them to MidjourneyWSEvents.
  void _handleWebSocketEvent(WebSocketEvent event) {
    for (final factory in _eventFactories) {
      final midjourneyEvent = factory.createFromWebSocketEvent(event);
      if (midjourneyEvent != null) {
        _eventsController.add(midjourneyEvent);
        return;
      }
    }
  }

  @override
  void subscribeToJob(String jobId) {
    final subscriptionMessage = jsonEncode({
      'job_id': jobId,
      'type': 'subscribe_to_job',
    });
    _webSocket?.sendBytes(utf8.encode(subscriptionMessage));
  }
}

/// Abstract interface for creating MidjourneyWSEvents from WebSocketEvents.
abstract class MidjourneyWSEventFactory {
  /// Creates a MidjourneyWSEvent from a WebSocketEvent.
  ///
  /// Returns null if the event cannot be converted.
  MidjourneyWSEvent? createFromWebSocketEvent(WebSocketEvent event);
}

/// Factory for creating MidjourneyWSDisconnectedEvents.
class MidjourneyWSDisconnectedEventFactory implements MidjourneyWSEventFactory {
  @override
  MidjourneyWSEvent? createFromWebSocketEvent(WebSocketEvent event) {
    if (event is CloseReceived) {
      return MidjourneyWSDisconnectedEvent(
        code: event.code,
        reason: event.reason,
      );
    }
    return null;
  }
}

/// Factory for creating MidjourneyWSJobSuccessEvents.
class MidjourneyWSJobSuccessEventFactory implements MidjourneyWSEventFactory {
  @override
  MidjourneyWSEvent? createFromWebSocketEvent(WebSocketEvent event) {
    if (event is TextDataReceived) {
      final data = jsonDecode(event.text);
      if (data case {'type': 'job_success', 'job_id': String jobId}) {
        return MidjourneyWSJobSuccessEvent(jobId: jobId);
      }
    }
    return null;
  }
}

/// Factory for creating MidjourneyWSGenerationStatusUpdateEvents.
class MidjourneyWSGenerationStatusUpdateEventFactory implements MidjourneyWSEventFactory {
  @override
  MidjourneyWSEvent? createFromWebSocketEvent(WebSocketEvent event) {
    if (event is TextDataReceived) {
      final data = jsonDecode(event.text) as Map<String, Object?>?;
      final currentStatus = data?['current_status'] as String?;
      final jobId = data?['job_id'] as String?;

      if (currentStatus != null && jobId != null) {
        final percentageComplete = (data?['percentage_complete'] as num?)?.toDouble();
        final status = MidjourneyWSGenerationStatus.fromValue(currentStatus);

        return MidjourneyWSGenerationStatusUpdateEvent(
          jobId: jobId,
          status: status,
          percentageComplete: percentageComplete,
        );
      }
    }
    return null;
  }
}