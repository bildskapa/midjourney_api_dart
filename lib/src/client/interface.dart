import 'package:midjourney_api_dart/api.dart';

/// An abstract interface class representing a client for interacting with the Midjourney API.
abstract interface class MidjourneyClient {
  /// Sends an imagine request to the Midjourney API.
  ///
  /// [prompt] is the text prompt for the imagine request.
  /// [channelId] is the ID of the channel where the request is made.
  /// [function] is the function options.
  /// [roomId] is an optional parameter specifying the room ID.
  ///
  /// Returns a [Future] that completes with a [MidjourneyJobResponse].
  Future<MidjourneyJobResponse> imagine({
    required String prompt,
    required String channelId,
    required MidjourneyFunction function,
    String? roomId,
  });

  /// Sends an upscale request to the Midjourney API.
  ///
  /// [id] is the ID of the job to be upscaled.
  /// [channelId] is the ID of the channel where the request is made.
  /// [function] is the function options.
  /// [type] is the type of upscale operation.
  /// [index] is the index of the image to be upscaled.
  /// [roomId] is an optional parameter specifying the room ID.
  ///
  /// Returns a [Future] that completes with a [MidjourneyJobResponse].
  Future<MidjourneyJobResponse> upscale({
    required String id,
    required String channelId,
    required MidjourneyFunction function,
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
  Future<void> connect({
    String version = '4',
  });

  /// Disconnects from the websocket server.
  Future<void> disconnect();

  /// Disposes client resources.
  Future<void> dispose();

  /// Stream of midjourney events.
  Stream<MidjourneyWSEvent> get events;

  /// Subscribes to job updates that are send to the stream.
  void subscribeToJob(String jobId);
}
