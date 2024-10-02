import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:midjourney_api_dart/src/client/interface.dart';
import 'package:midjourney_api_dart/src/const/config.dart';
import 'package:midjourney_api_dart/src/model/function.dart';
import 'package:midjourney_api_dart/src/model/midjourney_response.dart';

final class MidjourneyClientImpl implements MidjourneyClient {
  MidjourneyClientImpl({
    required MidjourneyConfig config,
    http.Client? httpClient,
  })  : _config = config,
        _httpClient = httpClient ?? http.Client();

  final MidjourneyConfig _config;
  final http.Client _httpClient;

  @override
  Future<MidjourneyJobResponse> imagine({
    required String prompt,
    required String channelId,
    required MidjourneyFunction f,
    String? roomId,
  }) async {
    final response = await _submitJobs(
      type: 'imagine',
      function: f,
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

    if (response
        case {
          'success': List<Object?> success,
          'failure': List<Object?> failure,
        }) {
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

  @override
  Future<MidjourneyJobResponse> upscale({
    required String id,
    required String channelId,
    required MidjourneyFunction f,
    required String type,
    required int index,
    String? roomId,
  }) async {
    final response = await _submitJobs(
      type: 'upscale',
      function: f,
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

    if (response
        case {
          'success': List<Object?> success,
          'failure': List<Object?> failure,
        }) {
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
      throw Exception('Failed to submit jobs: ${response.body}');
    }

    final json = jsonDecode(response.body);

    if (json is! Map<String, Object?>) {
      throw Exception('Unexpected JSON structure: $json');
    }

    return json;
  }
}
