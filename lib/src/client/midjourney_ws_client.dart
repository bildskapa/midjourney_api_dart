import 'dart:async';
import 'dart:convert';

import 'package:midjourney_api_dart/api.dart';
import 'package:web_socket/web_socket.dart';

/// Interface for the Midjourney WebSocket client.
class MidjourneyWSClientConfiguration {
  /// Creates a new instance of [MidjourneyWSClientConfiguration].
  const MidjourneyWSClientConfiguration({
    required this.wsUrl,
    required this.wsToken,
  });

  /// The WebSocket URL for the Midjourney API.
  final String wsUrl;

  /// The WebSocket token for the user.
  final String wsToken;
}

/// Implementation of the Midjourney WebSocket client.
base class MidjourneyWSClientBase implements MidjourneyWSClient {
  /// Constructor for the MidjourneyWSClientImpl.
  ///
  /// [config] is the configuration for the Midjourney API.
  /// [eventFactories] is a list of factories to create MidjourneyWSEvents.
  MidjourneyWSClientBase({
    required List<MidjourneyWSEventFactory> eventFactories,
    MidjourneyLogger? logger,
  })  : _eventFactories = eventFactories,
        _logger = logger ?? DefaultMidjourneyLogger();

  final List<MidjourneyWSEventFactory> _eventFactories;
  final MidjourneyLogger _logger;

  WebSocket? _webSocket;
  StreamSubscription? _webSocketSubscription;
  final _eventsController = StreamController<MidjourneyWSEvent>.broadcast();

  set configuration(MidjourneyWSClientConfiguration config) {
    _configuration = config;
  }

  /// The configuration for the Midjourney API.
  MidjourneyWSClientConfiguration? _configuration;

  /// The effective configuration for the Midjourney API.
  MidjourneyWSClientConfiguration get effectiveConfiguration =>
      _configuration ?? (throw Exception('Configuration not set'));

  @override
  Future<void> connect({
    String version = '4',
  }) async {
    final wsUrl = effectiveConfiguration.wsUrl;
    final wsUserToken = effectiveConfiguration.wsToken;

    final wsUri = Uri.parse('$wsUrl?token=$wsUserToken&v=$version');
    _webSocket = await WebSocket.connect(wsUri);
    _webSocketSubscription = _webSocket!.events.listen(_handleWebSocketEvent);
    _logger.info('Connected to Midjourney WebSocket at $wsUri');
  }

  @override
  Future<void> disconnect() async {
    await _webSocketSubscription?.cancel();
    await _webSocket?.close();
    _webSocket = null;
    _webSocketSubscription = null;
    _logger.info('Disconnected from Midjourney WebSocket');
  }

  @override
  Stream<MidjourneyWSEvent> get events => _eventsController.stream;

  /// Handles incoming [WebSocketEvent] and converts it to [MidjourneyWSEvent].
  void _handleWebSocketEvent(WebSocketEvent event) {
    _logger.trace(switch (event) {
      TextDataReceived() => 'Websocket received text: ${event.text}',
      BinaryDataReceived() => 'Websocket received binary data: ${event.data.length} bytes',
      CloseReceived() => 'Websocket closed: ${event.reason}, code: ${event.code}',
    });

    for (final factory in _eventFactories) {
      final midjourneyEvent = factory.createFromWebSocketEvent(event);
      if (midjourneyEvent != null) {
        _logger.trace('Created Midjourney event: $midjourneyEvent');
        _eventsController.add(midjourneyEvent);
        return;
      }
    }

    _logger.warn('Unhandled WebSocket event: $event');
  }

  @override
  void subscribeToJob(String jobId) => _sendCommand({'type': 'subscribe_to_job', 'job_id': jobId});

  void _sendCommand(Map<String, Object?> command) {
    _webSocket?.sendBytes(utf8.encode(jsonEncode(command)));
    _logger.trace('Sent command to Midjourney WebSocket: $command');
  }

  @override
  Future<void> dispose() async {
    await _eventsController.close();
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

/// Factory for creating [MidjourneyWSGenerationStatusUpdateEvent].
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
