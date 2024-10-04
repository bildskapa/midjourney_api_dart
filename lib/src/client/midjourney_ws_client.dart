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
  StreamSubscription? _webSocketSubscription;
  final _eventsController = StreamController<MidjourneyWSEvent>.broadcast();

  @override
  Future<void> connect({String version = '4'}) async {
    final wsUri = Uri.parse('${_config.wsUrl}?token=${_config.wsUserToken}&v=$version');
    _webSocket = await WebSocket.connect(wsUri);
    _webSocketSubscription = _webSocket!.events.listen(_handleWebSocketEvent);
    _config.logger.info('Connected to Midjourney WebSocket at $wsUri');
  }

  @override
  Future<void> disconnect() async {
    await _webSocketSubscription?.cancel();
    await _webSocket?.close();
    await _eventsController.close();
    _config.logger.info('Disconnected from Midjourney WebSocket');
  }

  @override
  Stream<MidjourneyWSEvent> get events => _eventsController.stream;

  /// Handles incoming [WebSocketEvent] and converts it to [MidjourneyWSEvent].
  void _handleWebSocketEvent(WebSocketEvent event) {
    _config.logger.trace(switch (event) {
      TextDataReceived() => 'Websocket received text: ${event.text}',
      BinaryDataReceived() => 'Websocket received binary data: ${event.data.length} bytes',
      CloseReceived() => 'Websocket closed: ${event.reason}, code: ${event.code}',
    });

    for (final factory in _eventFactories) {
      final midjourneyEvent = factory.createFromWebSocketEvent(event);
      if (midjourneyEvent != null) {
        _config.logger.trace('Created Midjourney event: $midjourneyEvent');
        _eventsController.add(midjourneyEvent);
        return;
      }
    }

    _config.logger.warn('Unhandled WebSocket event: $event');
  }

  @override
  void subscribeToJob(String jobId) => _sendCommand({'type': 'subscribe_to_job', 'job_id': jobId});

  void _sendCommand(Map<String, Object?> command) {
    _webSocket?.sendBytes(utf8.encode(jsonEncode(command)));
    _config.logger.trace('Sent command to Midjourney WebSocket: $command');
  }
}

/// Abstract interface for creating MidjourneyWSEvents from WebSocketEvents.
abstract interface class MidjourneyWSEventFactory {
  /// Creates a MidjourneyWSEvent from a WebSocketEvent.
  ///
  /// Returns null if the event is not recognized by this factory.
  MidjourneyWSEvent? createFromWebSocketEvent(WebSocketEvent event);
}

/// Factory for creating MidjourneyWSDisconnectedEvents.
final class MidjourneyWSDisconnectedEventFactory implements MidjourneyWSEventFactory {
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
final class MidjourneyWSJobSuccessEventFactory implements MidjourneyWSEventFactory {
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
final class MidjourneyWSGenerationStatusUpdateEventFactory implements MidjourneyWSEventFactory {
  @override
  MidjourneyWSEvent? createFromWebSocketEvent(WebSocketEvent event) {
    if (event is TextDataReceived) {
      final data = jsonDecode(event.text) as Map<String, Object?>?;
      final currentStatus = data?['current_status'] as String?;
      final jobId = data?['job_id'] as String?;

      if (currentStatus != null && jobId != null) {
        final percentageComplete = (data?['percentage_complete'] as num?)?.toDouble();
        final status = MidjourneyWSGenerationStatus.fromValue(currentStatus);
        final imageType = data?['img_type'] as String?;
        List<MidjourneyWSGenerationImage>? images;

        if (data?['imgs'] case List<Object?> imgs) {
          images = imgs
              .whereType<Map<String, Object?>>()
              .map(
                (imageJson) => MidjourneyWSGenerationImage(
                  filename: imageJson['filename'] as String,
                  data: imageJson['data'] as String,
                ),
              )
              .toList(growable: false);
        }

        return MidjourneyWSGenerationStatusUpdateEvent(
          jobId: jobId,
          status: status,
          percentageComplete: percentageComplete,
          imageType: imageType,
          images: images,
        );
      }
    }
    return null;
  }
}
