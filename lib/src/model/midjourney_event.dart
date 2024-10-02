/// All the events that can be emitted by the Midjourney Websocket
sealed class MidjourneyWebsocketEvent {}

class MidjourneyWSJobSuccessEvent extends MidjourneyWebsocketEvent {
  MidjourneyWSJobSuccessEvent({
    required this.jobId,
  });

  final String jobId;
}

class MidjourneyWSConnectedEvent extends MidjourneyWebsocketEvent {}

class MidjourneyWSDisconnectedEvent extends MidjourneyWebsocketEvent {}
