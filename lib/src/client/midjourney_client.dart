import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:midjourney_api_dart/src/client/interface.dart';
import 'package:midjourney_api_dart/src/model/f.dart';
import 'package:midjourney_api_dart/src/model/midjourney_response.dart';

class MidjourneyConfig {
  const MidjourneyConfig({
    required this.baseUrl,
    required this.authUserToken,
  });

  final String baseUrl;
  final String authUserToken;
}

final class MidjourneyClientImpl implements MidjourneyClient {
  MidjourneyClientImpl({
    required MidjourneyConfig config,
    http.Client? httpClient,
  })  : _config = config,
        _httpClient = httpClient ?? http.Client();

  final MidjourneyConfig _config;
  final http.Client _httpClient;

  @override
  Future<MidjourneyImagineResponse> imagine({
    required String prompt,
    required String channelId,
    required MidjourneyF f,
    String? roomId,
  }) async {
    final uri = Uri.parse('https://www.midjourney.com/api/app/submit-jobs');

    final response = await _httpClient.post(
      uri,
      body: jsonEncode({
        'prompt': prompt,
        'channelId': channelId,
        'roomId': roomId,
        'f': f.toJson(),
        't': 'imagine',
        'metadata': {
          'imagePrompts': 0,
          'imageReferences': 0,
          'characterReferences': 0,
        },
      }),
      headers: {
        'cookie': '__Host-Midjourney.AuthUserToken=${_config.authUserToken}',
        'cache-control': 'no-cache',
        'content-type': 'application/json',
        'x-csrf-protection': '1',
      },
    );

    final json = jsonDecode(response.body);

    return MidjourneyImagineResponse.fromJson(json);
  }

  @override
  Future<void> upscale({
    required String id,
    required String channelId,
    required MidjourneyF f,
    String? roomId,
  }) {
    // TODO: implement upscale
    throw UnimplementedError();
  }
}

/// Request URL: https://www.midjourney.com/api/app/submit-jobs <br/>
/// Request Method: POST
/// 
/// Payload:
/// ```json
/// {
///    "f":{
///       "mode":"relaxed",
///       "private":false
///    },
///    "channelId":"singleplayer_ac61c6c2-ceff-4ec5-b26a-fdac1318f29d",
///    "roomId":null,
///    "metadata":{
///       "imagePrompts":0,
///       "imageReferences":0,
///       "characterReferences":0
///    },
///    "t":"imagine",
///    "prompt":"Submit --v 6.1"
/// }
/// ```