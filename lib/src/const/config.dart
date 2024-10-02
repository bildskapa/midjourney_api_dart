/// A configuration class for the Midjourney API.
///
/// This class holds the necessary configuration details required to interact
/// with the Midjourney API, including the base URL and the authentication user token.
///
/// Example usage:
/// ```dart
/// const config = MidjourneyConfig(
///   baseUrl: 'https://api.midjourney.com',
///   authUserToken: 'your_auth_token',
/// );
/// ```
///
/// Properties:
/// - `baseUrl` (String): The base URL of the Midjourney API.
/// - `authUserToken` (String): The authentication token for the user.
class MidjourneyConfig {
  const MidjourneyConfig({
    required this.baseUrl,
    required this.authUserToken,
  });

  /// The base URL of the Midjourney API.
  /// 
  /// Example: 'https://api.midjourney.com'
  final String baseUrl;

  /// The authentication token for the user.
  final String authUserToken;
}