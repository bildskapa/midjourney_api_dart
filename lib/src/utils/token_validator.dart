import 'dart:convert';

/// A class responsible for validating and decoding authentication tokens.
class TokenValidator {
  /// Creates an [TokenValidator].
  const TokenValidator();

  /// Validates and decodes the provided [token].
  ///
  /// The token is expected to be in JWT format. It first decodes the outer token
  /// and validates that it contains an expected Firebase structure.
  /// If valid, it further decodes the inner `idToken` and returns a [DecodedAuthToken] object.
  ///
  /// Throws an [InvalidTokenException] if the token is invalid or improperly formatted.
  ///
  /// [token] - The JWT token to be validated and decoded.
  DecodedAuthToken validateAndDecodeAuthToken(String token) {
    try {
      final outerToken = _decodeToken(token);

      if (outerToken
          case {
            'type': 'firebase',
            'idToken': final String idToken,
            'refreshToken': final String refreshToken,
            'iat': final int iat
          }) {
        final innerToken = _decodeToken(idToken);
        return DecodedAuthToken(
          type: 'firebase',
          refreshToken: refreshToken,
          iat: DateTime.fromMillisecondsSinceEpoch(iat * 1000),
          idTokenDecoded: DecodedIdToken.fromJson(innerToken),
          idTokenEncoded: idToken,
        );
      } else {
        throw const InvalidTokenException('Invalid token structure');
      }
    } catch (e) {
      throw InvalidTokenException('Failed to decode token: $e');
    }
  }

  /// Validates and decodes the provided WebSocket [token].
  ///
  /// The token is a simple JSON string containing user-specific information.
  /// This method decodes the token and validates its structure.
  ///
  /// If valid, it returns a [DecodedWSToken] object.
  ///
  /// Throws an [InvalidTokenException] if the token is invalid or improperly formatted.
  DecodedWSToken validateAndDecodeWSToken(String token) {
    try {
      final decodedToken = _decodeToken(token);

      if (decodedToken
          case {
            'user_id': final String userId,
            'username': final String username,
            'iat': final int iat
          }) {
        return DecodedWSToken(
          userId: userId,
          username: username,
          iat: DateTime.fromMillisecondsSinceEpoch(iat * 1000),
        );
      } else {
        throw const InvalidTokenException('Invalid WebSocket token structure');
      }
    } catch (e) {
      throw InvalidTokenException('Failed to decode WebSocket token: $e');
    }
  }

  /// Helper method to decode a JWT token string into a Map.
  ///
  /// The token is split into 3 parts (header, payload, and signature). The method decodes
  /// the payload part, which is base64 URL encoded, into a Map.
  ///
  /// Throws an [InvalidTokenException] if the token doesn't contain exactly 3 parts.
  ///
  /// [token] - The JWT token to decode.
  Map<String, Object?> _decodeToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const InvalidTokenException('Token must have 3 parts');
    }
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return json.decode(decoded) as Map<String, Object?>;
  }
}

/// A class representing the decoded WebSocket token.
///
/// Contains user-specific information such as the user ID, username, and issued-at time [iat].
/// This token is used to authenticate WebSocket connections.
class DecodedWSToken {
  /// The user's unique ID.
  final String userId;

  /// The user's username.
  final String username;

  /// The issued-at time (iat) of the token, represented as a [DateTime].
  final DateTime iat;

  /// Creates a [DecodedWSToken] with the provided attributes.
  DecodedWSToken({
    required this.userId,
    required this.username,
    required this.iat,
  });
}

/// A class that represents a decoded authentication token.
///
/// Contains information such as the type of token, refresh token, issued-at time [iat],
/// and the decoded inner ID token [idTokenDecoded].
class DecodedAuthToken {
  /// The type of the token, typically 'firebase'.
  final String type;

  /// The refresh token, used to obtain new authentication tokens.
  final String refreshToken;

  /// The issued-at time (iat) of the token, represented as a [DateTime].
  final DateTime iat;

  /// The decoded inner ID token containing user information.
  final DecodedIdToken idTokenDecoded;

  /// The encoded ID token.
  final String idTokenEncoded;

  /// Creates a [DecodedAuthToken] with the provided attributes.
  DecodedAuthToken({
    required this.type,
    required this.refreshToken,
    required this.iat,
    required this.idTokenDecoded,
    required this.idTokenEncoded,
  });
}

/// A class representing the decoded ID token, which contains user-specific information.
///
/// This class holds various user attributes such as name, email, picture, and authentication details,
/// as well as Firebase-specific information.
class DecodedIdToken {
  /// The user's name.
  final String name;

  /// The URL to the user's profile picture.
  final String picture;

  /// The user's Midjourney ID.
  final String midjourneyId;

  /// The issuer of the token (iss), typically the Firebase project.
  final String iss;

  /// The audience of the token (aud), typically the Firebase project ID.
  final String aud;

  /// The time the user was authenticated (auth_time), represented as a [DateTime].
  final DateTime authTime;

  /// The user's unique ID in Firebase.
  final String userId;

  /// The subject of the token (sub), typically the user's unique identifier.
  final String sub;

  /// The issued-at time (iat) of the token, represented as a [DateTime].
  final DateTime iat;

  /// The expiration time (exp) of the token, represented as a [DateTime].
  final DateTime exp;

  /// The user's email address.
  final String email;

  /// Whether the user's email has been verified.
  final bool emailVerified;

  /// Creates a [DecodedIdToken] with the provided attributes.
  DecodedIdToken({
    required this.name,
    required this.picture,
    required this.midjourneyId,
    required this.iss,
    required this.aud,
    required this.authTime,
    required this.userId,
    required this.sub,
    required this.iat,
    required this.exp,
    required this.email,
    required this.emailVerified,
  });

  /// Factory constructor to create a [DecodedIdToken] instance from a JSON map.
  ///
  /// This parses various fields, including timestamps.
  factory DecodedIdToken.fromJson(Map<String, Object?> json) => DecodedIdToken(
        name: json['name']! as String,
        picture: json['picture']! as String,
        midjourneyId: json['midjourney_id']! as String,
        iss: json['iss']! as String,
        aud: json['aud']! as String,
        authTime: DateTime.fromMillisecondsSinceEpoch((json['auth_time']! as int) * 1000),
        userId: json['user_id']! as String,
        sub: json['sub']! as String,
        iat: DateTime.fromMillisecondsSinceEpoch((json['iat']! as int) * 1000),
        exp: DateTime.fromMillisecondsSinceEpoch((json['exp']! as int) * 1000),
        email: json['email']! as String,
        emailVerified: json['email_verified']! as bool,
      );
}

/// An abstract sealed class for exceptions related to token validation.
///
/// [message] contains the error message for the exception.
sealed class AuthTokenValidationException implements Exception {
  /// The error message associated with the exception.
  final String message;
  const AuthTokenValidationException(this.message);
}

/// Exception thrown when a token is invalid.
///
/// Inherits from [AuthTokenValidationException].
final class InvalidTokenException extends AuthTokenValidationException {
  /// Creates an [InvalidTokenException] with the provided [message].
  const InvalidTokenException(super.message);
}
