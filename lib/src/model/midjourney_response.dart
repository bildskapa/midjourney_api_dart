class MidjourneyImagineResponse {
  MidjourneyImagineResponse({
    required this.success,
    required this.failure,
  });

  /// Successful jobs.
  final List<MidjourneyImagineJobSuccess> success;

  /// Failed jobs.
  final List<MidjourneyJobFailure> failure;

  /// Constructs the object from a JSON object.
  static MidjourneyImagineResponse fromJson(Map<String, Object?> json) {
    if (json
        case {
          'success': List<Object?> success,
          'failure': List<Object?> failure,
        }) {
      return MidjourneyImagineResponse(
        success: success.whereType<Map<String, Object?>>().map(MidjourneyImagineJobSuccess.fromJson).toList(),
        failure: failure.whereType<Map<String, Object?>>().map(MidjourneyJobFailure.fromJson).toList(),
      );
    }

    throw FormatException('Unexpected JSON structure');
  }

  @override
  String toString() => 'MidjourneyImagineResponse(success: $success, failure: $failure)';
}

class MidjourneyImagineJobSuccess {
  MidjourneyImagineJobSuccess({
    required this.id,
    required this.prompt,
    required this.isQueued,
    required this.eventType,
  });

  final String id;
  final String prompt;
  final bool isQueued;
  final String eventType;

  /// Constructs the object from a JSON object.
  static MidjourneyImagineJobSuccess fromJson(Map<String, Object?> json) {
    if (json
        case {
          'job_id': String id,
          'prompt': String prompt,
          'is_queued': bool isQueued,
          'event_type': String eventType,
        }) {
      return MidjourneyImagineJobSuccess(
        id: id,
        prompt: prompt,
        isQueued: isQueued,
        eventType: eventType,
      );
    }

    throw FormatException(
      'Unexpected JSON structure for MidjourneyImagineJobSuccess',
      json,
    );
  }

  @override
  String toString() => 'MidjourneyImagineJobSuccess('
      'id: $id, '
      'prompt: $prompt, '
      'isQueued: $isQueued, '
      'eventType: $eventType'
      ')';
}

class MidjourneyJobFailure {
  const MidjourneyJobFailure({
    required this.type,
    required this.message,
  });

  final String type;
  final String message;

  static MidjourneyJobFailure fromJson(Map<String, Object?> json) {
    if (json
        case {
          'type': String type,
          'message': String message,
        }) {
      return MidjourneyJobFailure(
        type: type,
        message: message,
      );
    }

    throw FormatException(
      'Unexpected JSON structure for MidjourneyJobFailure',
      json,
    );
  }

  @override
  String toString() => 'MidjourneyJobFailure(type: $type, message: $message)';
}
