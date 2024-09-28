import 'package:midjourney_api_dart/src/model/f.dart';
import 'package:midjourney_api_dart/src/model/midjourney_event.dart';

abstract interface class MidjourneyClient {
  Future<void> imagine({
    required String prompt,
    required String channelId,
    required MidjourneyF f,
    String? roomId,
  });

  Future<void> upscale({
    required String prompt,
    required String channelId,
    required MidjourneyF f,
    String? roomId,
  });
}

abstract interface class MidjourneyWSClient {
  Future<void> connect();

  Future<void> disconnect();

  /// Stream of midjourney events.
  Stream<MidjourneyWebsocketEvent> get events;

  /// Subscribes to job updates that are send to the stream.
  Future<void> subscribeToJob(String jobId);
}
