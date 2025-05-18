import 'package:midjourney_api_dart/api.dart';

/// A class representing a Midjourney job.
class MidjourneyJob {
  /// Creates a new instance of [MidjourneyJob].
  MidjourneyJob({
    required this.id,
    required this.enqueueTime,
    required this.jobType,
    required this.eventType,
    required this.fullCommand,
    required this.batchSize,
    required this.width,
    required this.height,
    required this.published,
    required this.shown,
    this.parentId,
    this.rating,
    this.parentGrid,
  });

  final String id;
  final DateTime enqueueTime;
  final String? parentId;
  final dynamic rating;
  final String jobType;
  final String eventType;
  final int? parentGrid;
  final String fullCommand;
  final int batchSize;
  final int width;
  final int height;
  final bool published;
  final bool shown;

  factory MidjourneyJob.fromJson(Map<String, dynamic> json) {
    return MidjourneyJob(
      id: json['id'],
      enqueueTime: DateTime.parse(json['enqueue_time']),
      parentId: json['parent_id'],
      rating: json['rating'],
      jobType: json['job_type'],
      eventType: json['event_type'],
      parentGrid: json['parent_grid'],
      fullCommand: json['full_command'],
      batchSize: json['batch_size'],
      width: json['width'],
      height: json['height'],
      published: json['published'],
      shown: json['shown'],
    );
  }

  // Equality and hashCode methods
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidjourneyJob &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          enqueueTime == other.enqueueTime &&
          parentId == other.parentId &&
          rating == other.rating &&
          jobType == other.jobType &&
          eventType == other.eventType &&
          parentGrid == other.parentGrid &&
          fullCommand == other.fullCommand &&
          batchSize == other.batchSize &&
          width == other.width &&
          height == other.height &&
          published == other.published &&
          shown == other.shown;

  @override
  int get hashCode =>
      id.hashCode ^
      enqueueTime.hashCode ^
      parentId.hashCode ^
      rating.hashCode ^
      jobType.hashCode ^
      eventType.hashCode ^
      parentGrid.hashCode ^
      fullCommand.hashCode ^
      batchSize.hashCode ^
      width.hashCode ^
      height.hashCode ^
      published.hashCode ^
      shown.hashCode;
}

// The response class for the MidjourneyJob data
class MidjourneyJobsResponse extends MidjourneyResponse {
  final List<MidjourneyJob> data;
  final String cursor;
  final String checkpoint;

  MidjourneyJobsResponse({
    required this.data,
    required this.cursor,
    required this.checkpoint,
    super.additionalData,
  });

  // Construct [MidjourneyJobResponse] from a JSON map
  factory MidjourneyJobsResponse.fromJson(Map<String, dynamic> json) {
    final jobsJson = json['data'] as List<Object?>;
    final jobsList = jobsJson
        .whereType<Map<String, Object?>>()
        .map(MidjourneyJob.fromJson)
        .toList(growable: false);

    return MidjourneyJobsResponse(
      data: jobsList,
      cursor: json['cursor'],
      checkpoint: json['checkpoint'],
    );
  }
}
