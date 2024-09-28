sealed class MidjourneyWebsocketEvent {}

class MidjourneyWSJobSuccessEvent extends MidjourneyWebsocketEvent {
  MidjourneyWSJobSuccessEvent({
    required this.jobId,
  });

  final String jobId;
}