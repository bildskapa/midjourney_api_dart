import 'package:collection/collection.dart';

/// All the events that can be emitted by the Midjourney Websocket
sealed class MidjourneyWSEvent {
  const MidjourneyWSEvent();
}

final class MidjourneyWSJobSuccessEvent extends MidjourneyWSEvent {
  const MidjourneyWSJobSuccessEvent({
    required this.jobId,
  });

  final String jobId;

  @override
  int get hashCode => jobId.hashCode;

  @override
  bool operator ==(Object other) => other is MidjourneyWSJobSuccessEvent && other.jobId == jobId;

  @override
  String toString() => 'MidjourneyWSJobSuccessEvent(jobId: $jobId)';
}

final class MidjourneyWSDisconnectedEvent extends MidjourneyWSEvent {
  /// Creates a [MidjourneyWSDisconnectedEvent].
  ///
  /// [code] is the disconnect code.
  /// [reason] is the disconnect reason.
  const MidjourneyWSDisconnectedEvent({
    this.code,
    required this.reason,
  });

  /// Disconnect code
  final int? code;

  /// Disconnect reason
  final String reason;

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) => other is MidjourneyWSDisconnectedEvent;

  @override
  String toString() => 'MidjourneyWSDisconnectedEvent';
}

final class MidjourneyWSGenerationStatusUpdateEvent extends MidjourneyWSEvent {
  MidjourneyWSGenerationStatusUpdateEvent({
    required this.status,
    required this.jobId,
    this.percentageComplete,
    this.imageType,
    this.images,
  });

  final MidjourneyWSGenerationStatus status;
  final String jobId;
  final double? percentageComplete;
  final String? imageType;
  final List<MidjourneyWSGenerationImage>? images;

  @override
  int get hashCode =>
      status.hashCode ^
      jobId.hashCode ^
      percentageComplete.hashCode ^
      imageType.hashCode ^
      DeepCollectionEquality().hash(images);

  @override
  bool operator ==(Object other) =>
      other is MidjourneyWSGenerationStatusUpdateEvent &&
      other.status == status &&
      other.jobId == jobId &&
      other.percentageComplete == percentageComplete &&
      other.imageType == imageType &&
      DeepCollectionEquality().equals(other.images, images);

  @override
  String toString() {
    final buffer = StringBuffer('MidjourneyWSGenerationStatusUpdateEvent(');
    buffer.write('status: $status, ');
    buffer.write('jobId: $jobId, ');
    buffer.write('percentageComplete: $percentageComplete, ');
    buffer.write('imageType: $imageType, ');
    buffer.write('images: $images');
    buffer.write(')');

    return buffer.toString();
  }
}

class MidjourneyWSGenerationImage {
  MidjourneyWSGenerationImage({
    required this.filename,
    required this.data,
  });

  final String filename;
  final String data;

  @override
  int get hashCode => filename.hashCode ^ data.hashCode;

  @override
  bool operator ==(Object other) =>
      other is MidjourneyWSGenerationImage && other.filename == filename && other.data == data;

  @override
  String toString() => 'MidjourneyWSGenerationImage(filename: $filename, data: $data)';
}

enum MidjourneyWSGenerationStatus {
  unqueue._('unqueue'),
  startStage._('start_stage'),
  running._('running'),
  completed._('completed'),
  ;

  const MidjourneyWSGenerationStatus._(this.value);

  final String value;

  static MidjourneyWSGenerationStatus fromValue(String value) => values.firstWhere((e) => e.value == value);
}
