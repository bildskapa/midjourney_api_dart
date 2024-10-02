import 'package:midjourney_api_dart/src/model/function.dart';
import 'package:midjourney_api_dart/src/model/midjourney_event.dart';
import 'package:midjourney_api_dart/src/model/midjourney_response.dart';

abstract interface class MidjourneyClient {
  Future<MidjourneyJobResponse> imagine({
    required String prompt,
    required String channelId,
    required MidjourneyFunction f,
    String? roomId,
  });

  Future<MidjourneyJobResponse> upscale({
    required String id,
    required String channelId,
    required MidjourneyFunction f,
    required String type,
    required int index,
    String? roomId,
  });
}

abstract interface class MidjourneyWSClient {
  /// Connects to the websocket server.
  /// 
  /// If the connection is already established, this method does nothing.
  /// 
  /// When disconnected, the client will automatically try to reconnect.
  Future<void> connect();

  /// Disconnects from the websocket server.
  Future<void> disconnect();

  /// Stream of midjourney events.
  Stream<MidjourneyWebsocketEvent> get events;

  /// Subscribes to job updates that are send to the stream.
  Future<void> subscribeToJob(String jobId);
}
