/// Represents the response from a Midjourney imagine request.
///
/// This class encapsulates both successful and failed job results.
class MidjourneyJobResponse {
  /// Constructs a [MidjourneyJobResponse] with lists of successful and failed jobs.
  const MidjourneyJobResponse({
    required this.success,
    required this.failure,
  });

  /// List of successful imagine jobs.
  final List<MidjourneyJobSuccess> success;

  /// List of failed imagine jobs.
  final List<MidjourneyJobFailure> failure;

  /// Constructs the object from a JSON map.
  ///
  /// Throws a [FormatException] if the JSON structure is unexpected.
  factory MidjourneyJobResponse.fromJson(Map<String, Object?> json) {
    if (json case {'success': List<Object?> successList, 'failure': List<Object?> failureList}) {
      return MidjourneyJobResponse(
        success: successList.whereType<Map<String, Object?>>().map(MidjourneyJobSuccess.fromJson).toList(),
        failure: failureList.whereType<Map<String, Object?>>().map(MidjourneyJobFailure.fromJson).toList(),
      );
    }
    throw FormatException('Unexpected JSON structure for MidjourneyImagineResponse', json);
  }

  /// Converts the object to a JSON map.
  Map<String, Object?> toJson() => {
        'success': success.map((job) => job.toJson()).toList(),
        'failure': failure.map((job) => job.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidjourneyJobResponse &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          failure == other.failure;

  @override
  int get hashCode => success.hashCode ^ failure.hashCode;

  @override
  String toString() => 'MidjourneyJobResponse(success: $success, failure: $failure)';
}

/// Represents a successful Midjourney imagine job.
class MidjourneyJobSuccess {
  /// Constructs a [MidjourneyJobSuccess] with job details.
  const MidjourneyJobSuccess({
    required this.id,
    required this.prompt,
    required this.isQueued,
    required this.eventType,
  });

  /// Unique identifier for the job.
  final String id;

  /// The prompt used for the imagine job.
  final String prompt;

  /// Indicates whether the job is queued or not.
  final bool isQueued;

  /// The type of event associated with this job.
  final String eventType;

  /// Constructs the object from a JSON map.
  ///
  /// Throws a [FormatException] if the JSON structure is unexpected.
  factory MidjourneyJobSuccess.fromJson(Map<String, Object?> json) {
    if (json
        case {
          'job_id': String id,
          'prompt': String prompt,
          'is_queued': bool isQueued,
          'event_type': String eventType,
        }) {
      return MidjourneyJobSuccess(
        id: id,
        prompt: prompt,
        isQueued: isQueued,
        eventType: eventType,
      );
    }
    throw FormatException('Unexpected JSON structure for MidjourneyImagineJobSuccess', json);
  }

  /// Converts the object to a JSON map.
  Map<String, Object?> toJson() => {
        'job_id': id,
        'prompt': prompt,
        'is_queued': isQueued,
        'event_type': eventType,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidjourneyJobSuccess &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          prompt == other.prompt &&
          isQueued == other.isQueued &&
          eventType == other.eventType;

  @override
  int get hashCode => id.hashCode ^ prompt.hashCode ^ isQueued.hashCode ^ eventType.hashCode;

  @override
  String toString() =>
      'MidjourneyJobSuccess(id: $id, prompt: $prompt, isQueued: $isQueued, eventType: $eventType)';
}

/// Represents a failed Midjourney job.
class MidjourneyJobFailure {
  /// Constructs a [MidjourneyJobFailure] with error details.
  const MidjourneyJobFailure({
    required this.type,
    required this.message,
  });

  /// The type of failure that occurred.
  final String type;

  /// A descriptive message about the failure.
  final String message;

  /// Constructs the object from a JSON map.
  ///
  /// Throws a [FormatException] if the JSON structure is unexpected.
  factory MidjourneyJobFailure.fromJson(Map<String, Object?> json) {
    if (json case {'type': String type, 'message': String message}) {
      return MidjourneyJobFailure(
        type: type,
        message: message,
      );
    }
    throw FormatException('Unexpected JSON structure for MidjourneyJobFailure', json);
  }

  /// Converts the object to a JSON map.
  Map<String, Object?> toJson() => {
        'type': type,
        'message': message,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidjourneyJobFailure &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message;

  @override
  int get hashCode => type.hashCode ^ message.hashCode;

  @override
  String toString() => 'MidjourneyJobFailure(type: $type, message: $message)';
}
