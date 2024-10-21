import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:midjourney_api_dart/api.dart';
import 'package:midjourney_api_dart/src/utils/token_validator.dart';

/// The configuration provider for the Midjourney API.
class MidjourneyClientConfiguration {
  /// Creates a new instance of [MidjourneyClientConfiguration].
  const MidjourneyClientConfiguration({
    required this.authUserTokenV3I,
    required this.authUserTokenV3R,
    required this.baseUrl,
  });

  /// The authentication token for the user.
  final String authUserTokenV3I;

  /// The refresh token for the user.
  final String authUserTokenV3R;

  /// The base URL for the Midjourney API.
  final String baseUrl;
}

/// Implementation of the MidjourneyClient interface.
/// This class provides methods to interact with the Midjourney API.
base class MidjourneyClientBase implements MidjourneyClient {
  /// Creates a new instance of [MidjourneyClientBase].
  ///
  /// [config] is required and contains the configuration for the Midjourney API.
  /// [httpClient] is optional and can be provided for custom HTTP handling.
  MidjourneyClientBase({
    required MidjourneyLogger logger,
    http.Client? httpClient,
  })  : _logger = logger,
        _httpClient = httpClient ?? http.Client();

  final MidjourneyLogger _logger;
  final http.Client _httpClient;

  MidjourneyClientConfiguration? _configuration;

  set configuration(MidjourneyClientConfiguration config) {
    _configuration = config;
  }

  MidjourneyClientConfiguration get effectiveConfiguration =>
      _configuration ?? (throw Exception('Configuration not set'));

  @override
  Future<ThomasJobResponse> getJobs({
    required int pageSize,
  }) async {
    final decodedToken = const TokenValidator().validateAndDecodeAuthTokenV3I(
      effectiveConfiguration.authUserTokenV3I,
    );

    final userId = decodedToken.midjourneyId;

    final response = await _httpClient.get(
      Uri.parse('${effectiveConfiguration.baseUrl}/api/pg/thomas-jobs?user_id=$userId&page_size=$pageSize'),
      headers: _getAuthHeaders(
        authUserTokenV3I: effectiveConfiguration.authUserTokenV3I,
        authUserTokenV3R: effectiveConfiguration.authUserTokenV3R,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get jobs: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body);

    if (json is! Map<String, Object?>) {
      throw FormatException('Unexpected JSON structure', json, 0);
    }

    final thomasResponse = ThomasJobResponse.fromJson(json);
    _ensureTokensUpdated(thomasResponse);

    return thomasResponse;
  }

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
    final job = await _submitJobs(
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

    _logger.trace('Submitted imagine job: $job');

    return job;
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
    final job = await _submitJobs(
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
    _logger.trace('Submitted upscale job: $job');

    return job;
  }

  /// Submits jobs to the Midjourney API.
  ///
  /// This is a private method used by both [imagine] and [upscale].
  Future<MidjourneyJobResponse> _submitJobs({
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
      Uri.parse('${effectiveConfiguration.baseUrl}/api/app/submit-jobs'),
      body: jsonEncodedBody,
      headers: _getAuthHeaders(
        authUserTokenV3I: effectiveConfiguration.authUserTokenV3I,
        authUserTokenV3R: effectiveConfiguration.authUserTokenV3R,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit jobs: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body);

    if (json is! Map<String, Object?>) {
      throw Exception('Unexpected JSON structure: $json');
    }

    final job = _parseJobResponse(json);
    _ensureTokensUpdated(job);

    return job;
  }

  Map<String, String> _getAuthHeaders({
    required String authUserTokenV3I,
    required String authUserTokenV3R,
  }) {
    final cookieBuilder = StringBuffer();
    cookieBuilder.write('__Host-Midjourney.AuthUserTokenV3_i=$authUserTokenV3I; ');
    cookieBuilder.write('__Host-Midjourney.AuthUserTokenV3_r=$authUserTokenV3R');

    return {
      'cookie': cookieBuilder.toString(),
      'content-type': 'application/json',
      'x-csrf-protection': '1',
      'origin': effectiveConfiguration.baseUrl,
    };
  }

  void _ensureTokensUpdated(MidjourneyResponse response) {
    if (response.additionalData
        case MidjourneyAdditionalData(
          :final String authTokenV3I,
          :final String authTokenV3R,
        )) {
      _configuration = MidjourneyClientConfiguration(
        authUserTokenV3I: authTokenV3I,
        authUserTokenV3R: authTokenV3R,
        baseUrl: effectiveConfiguration.baseUrl,
      );
    }
  }

  /// Parses the job response from the API.
  ///
  /// This method is used to convert the API response into a [MidjourneyJobResponse] object.
  MidjourneyJobResponse _parseJobResponse(Map<String, Object?> response) =>
      MidjourneyJobResponse.fromJson(response);
}
