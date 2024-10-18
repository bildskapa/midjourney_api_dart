import 'package:midjourney_api_dart/api.dart';

const _authTokenV3I =
    'eyJhbGciOiJSUzI1NiIsImtpZCI6IjhkOWJlZmQzZWZmY2JiYzgyYzgzYWQwYzk3MmM4ZWE5NzhmNmYxMzciLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoibWljaGFlbGxhemVibnkiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jSV8wNEJxcW1Cc1ZwODBjakZNeEJXV2lSNF9ZZEN6b2hHV3RFWWw5WVdnVFJLZWpqd049czk2LWMiLCJtaWRqb3VybmV5X2lkIjoiYWM2MWM2YzItY2VmZi00ZWM1LWIyNmEtZmRhYzEzMThmMjlkIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL2F1dGhqb3VybmV5IiwiYXVkIjoiYXV0aGpvdXJuZXkiLCJhdXRoX3RpbWUiOjE3MjkxODk0NzksInVzZXJfaWQiOiJmUzVXa2JIcmQ0YTJ1aXlEU2RaWVk4ZEwzQVQyIiwic3ViIjoiZlM1V2tiSHJkNGEydWl5RFNkWllZOGRMM0FUMiIsImlhdCI6MTcyOTE4OTY2MiwiZXhwIjoxNzI5MTkzMjYyLCJlbWFpbCI6Im1pc2thZGwwOUBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJnb29nbGUuY29tIjpbIjExNjMyNTQ1MTc1NzA3NDA0MDk1MyJdLCJkaXNjb3JkLmNvbSI6WyIyOTI2MjU1NTAwNTEyNDYwODAiXSwiZW1haWwiOlsibWlza2FkbDA5QGdtYWlsLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6Imdvb2dsZS5jb20ifX0.Uq3AcyS8MHOj6hJb-Db75JclyL3P0p3t-h_0h7RHEBN7edVMB58Hvz9w2P3rkR0LLCfrlMSLJq1b7pL2RePkDbJw2JxFmGYKdUNh1d9QhXMiiIa9MF9_sFxq5EHBYf7732EfKrC6hjhK6_1MH-budKyUxcF6ek2az2KTn9utcBcDmDJzoo66FrVbOfGXJjB0uAXYRiDmcAJF5EzHQa1huLNzSfWYq5r7pbn-qRc5SuErmJD-ml9DYf_BpxTvd5Yy6WRGbSeTqeEUOgOiPp2mTfiZXMB2M09W4GZNbngre5mX2iIvNgFbbk5BPHVgCIOEIHunCAVoVmoJoPdJsq8Vwg';

const _authTokenV3R =
    'AMf-vBxUugN2tt_hsqGYClPjYNByUUYSqLBUJJtdadwyT7J_bG9Md-wWc9N25c1IFAcsz964tksa7tl-eNT-mZzpQm9JddihSO02FzdH_UsGDIJl7eSw10SyIZfZ3L-1wXy5SwM9owCZ5sxwR8Zn9Ln6JITkNbYcMGTvThhY5IsK_svrjcYBJ8r2jQFfV8RDsO2vkA9fh4RkoKPAHNl_FLMYG5q4zhu1k_pZ1UnUgtIWRdQFa1v46lk5bPHq-vEV_KgB5DSb1BjmYuKNXgFn7rgUCL-hIyDN18SNllQlxlmGDETicwSfpM9TeFlr4uzQYYY37QwJRYraRUtmzInG3lo6dC-4SqhpsND5swt74yeK9Kz5x0jkgXZFs526yTEN2HENlHCGG_ydqyPhfQhkVa5slBmvMIRuf8x4GlEnmEfY75aaJQEPwqc';

const _wsToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYWM2MWM2YzItY2VmZi00ZWM1LWIyNmEtZmRhYzEzMThmMjlkIiwidXNlcm5hbWUiOiJtaWNoYWVsbGF6ZWJueSIsImlhdCI6MTcyOTE4OTQ3OX0.c7VwohkNSmyi1AcIEbctrdsnN-bsFdkRSJEsGSzIeGQ';

Future<void> main() async {
  final logger = DefaultMidjourneyLogger(LoggingOptions(level: LogLevel.trace));

  final client = MidjourneyClientBase(logger: logger);

  client.configuration = MidjourneyClientConfiguration(
    baseUrl: 'https://www.midjourney.com',
    authUserTokenV3I: _authTokenV3I,
    authUserTokenV3R: _authTokenV3R,
  );

  final imagineResponse = await client.imagine(
    prompt: 'Midjourney2 --v 6.1',
    channelId: 'singleplayer_ac61c6c2-ceff-4ec5-b26a-fdac1318f29d',
    function: MidjourneyFunction(mode: MidjourneyMode.relaxed, private: false),
  );

  final midjourneyWSClient = MidjourneyWSClientBase(
    logger: logger,
    eventFactories: [
      MidjourneyWSDisconnectedEventFactory(),
      MidjourneyWSJobSuccessEventFactory(),
      MidjourneyWSGenerationStatusUpdateEventFactory(),
    ],
  );

  midjourneyWSClient.configuration = MidjourneyWSClientConfiguration(
    wsUrl: 'wss://ws.midjourney.com/ws',
    wsToken: _wsToken,
  );

  await midjourneyWSClient.connect();

  midjourneyWSClient.subscribeToJob(imagineResponse.success.first.id);

  String? jobId;

  // await for success event
  await for (final event in midjourneyWSClient.events) {
    if (event is MidjourneyWSGenerationStatusUpdateEvent && event.percentageComplete == 100) {
      jobId = event.jobId;
      break;
    }
  }

  if (jobId == null) {
    throw Exception('Job ID not found');
  }

  // await for generation status update event
  final upscaleResponse = await client.upscale(
    id: jobId,
    channelId: 'singleplayer_ac61c6c2-ceff-4ec5-b26a-fdac1318f29d',
    function: MidjourneyFunction(mode: MidjourneyMode.relaxed, private: false),
    type: 'v6r1_2x_subtle',
    index: 0,
  );

  midjourneyWSClient.subscribeToJob(upscaleResponse.success.first.id);
}
