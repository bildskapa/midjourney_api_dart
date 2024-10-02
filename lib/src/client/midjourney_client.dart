import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:midjourney_api_dart/src/client/interface.dart';
import 'package:midjourney_api_dart/src/const/config.dart';
import 'package:midjourney_api_dart/src/model/function.dart';
import 'package:midjourney_api_dart/src/model/midjourney_response.dart';

/// Implementation of the MidjourneyClient interface.
/// This class provides methods to interact with the Midjourney API.
final class MidjourneyClientImpl implements MidjourneyClient {
  /// Creates a new instance of [MidjourneyClientImpl].
  ///
  /// [config] is required and contains the configuration for the Midjourney API.
  /// [httpClient] is optional and can be provided for custom HTTP handling.
  MidjourneyClientImpl({
    required MidjourneyConfig config,
    http.Client? httpClient,
  })  : _config = config,
        _httpClient = httpClient ?? http.Client();

  final MidjourneyConfig _config;
  final http.Client _httpClient;

  /// Submits an 'imagine' job to the Midjourney API.
  ///
  /// [prompt] is the text prompt for image generation.
  /// [channelId] is the ID of the channel where the job will be submitted.
  /// [function] specifies the Midjourney function to use.
  /// [roomId] is optional and can be used to specify a room.
  @override
  Future<MidjourneyJobResponse> imagine({
    required String prompt,
    required String channelId,
    required MidjourneyFunction function,
    String? roomId,
  }) async {
    final response = await _submitJobs(
      type: 'imagine',
      function: function,
      channelId: channelId,
      roomId: roomId,
      body: {
        'prompt': prompt,
        'metadata': {
          'imagePrompts': 0,
          'imageReferences': 0,
          'characterReferences': 0,
        },
      },
    );

    return _parseJobResponse(response);
  }

  /// Submits an 'upscale' job to the Midjourney API.
  ///
  /// [id] is the ID of the image to upscale.
  /// [channelId] is the ID of the channel where the job will be submitted.
  /// [function] specifies the Midjourney function to use.
  /// [type] is the type of upscale operation.
  /// [index] is the index of the image to upscale.
  /// [roomId] is optional and can be used to specify a room.
  @override
  Future<MidjourneyJobResponse> upscale({
    required String id,
    required String channelId,
    required MidjourneyFunction function,
    required String type,
    required int index,
    String? roomId,
  }) async {
    final response = await _submitJobs(
      type: 'upscale',
      function: function,
      channelId: channelId,
      roomId: roomId,
      body: {
        'id': id,
        'type': type,
        'index': index,
        'metadata': {
          'imagePrompts': null,
          'imageReferences': null,
          'characterReferences': null,
        },
      },
    );

    return _parseJobResponse(response);
  }

  /// Submits jobs to the Midjourney API.
  ///
  /// This is a private method used by both [imagine] and [upscale].
  Future<Map<String, Object?>> _submitJobs({
    required String type,
    required String channelId,
    required MidjourneyFunction function,
    required Map<String, Object?> body,
    String? roomId,
  }) async {
    final jsonEncodedBody = jsonEncode({
      't': type,
      'f': function.toJson(),
      'channelId': channelId,
      'roomId': roomId,
      ...body,
    });

    final response = await _httpClient.post(
      Uri.parse('${_config.baseUrl}/api/app/submit-jobs'),
      body: jsonEncodedBody,
      headers: {
        'cookie': '__Host-Midjourney.AuthUserToken=${_config.authUserToken}',
        'content-type': 'application/json',
        'x-csrf-protection': '1',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit jobs: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body);

    if (json is! Map<String, Object?>) {
      throw Exception('Unexpected JSON structure: $json');
    }

    return json;
  }

  /// Parses the job response from the API.
  ///
  /// This method is used to convert the API response into a [MidjourneyJobResponse] object.
  MidjourneyJobResponse _parseJobResponse(Map<String, Object?> response) {
    if (response case {'success': List<Object?> success, 'failure': List<Object?> failure}) {
      return MidjourneyJobResponse(
        success: success
            .whereType<Map<String, Object?>>()
            .map(MidjourneyJobSuccess.fromJson)
            .toList(growable: false),
        failure: failure
            .whereType<Map<String, Object?>>()
            .map(MidjourneyJobFailure.fromJson)
            .toList(growable: false),
      );
    }

    throw Exception('Unexpected JSON structure: $response');
  }
}
