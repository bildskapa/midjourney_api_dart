

// Model class for the Job data
class ThomasJob {
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

  ThomasJob({
    required this.id,
    required this.enqueueTime,
    this.parentId,
    this.rating,
    required this.jobType,
    required this.eventType,
    this.parentGrid,
    required this.fullCommand,
    required this.batchSize,
    required this.width,
    required this.height,
    required this.published,
    required this.shown,
  });

  // Equality and hashCode methods
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThomasJob &&
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

  // fromJson factory
  factory ThomasJob.fromJson(Map<String, dynamic> json) {
    return ThomasJob(
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

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enqueue_time': enqueueTime.toIso8601String(),
      'parent_id': parentId,
      'rating': rating,
      'job_type': jobType,
      'event_type': eventType,
      'parent_grid': parentGrid,
      'full_command': fullCommand,
      'batch_size': batchSize,
      'width': width,
      'height': height,
      'published': published,
      'shown': shown,
    };
  }
}

// Model class for the root object
class ThomasJobResponse {
  final List<ThomasJob> data;
  final String cursor;
  final String checkpoint;

  ThomasJobResponse({
    required this.data,
    required this.cursor,
    required this.checkpoint,
  });

  // fromJson factory
  factory ThomasJobResponse.fromJson(Map<String, dynamic> json) {
    var jobsJson = json['data'] as List;
    List<ThomasJob> jobsList = jobsJson.map((job) => ThomasJob.fromJson(job)).toList();

    return ThomasJobResponse(
      data: jobsList,
      cursor: json['cursor'],
      checkpoint: json['checkpoint'],
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'data': data.map((job) => job.toJson()).toList(),
      'cursor': cursor,
      'checkpoint': checkpoint,
    };
  }
}