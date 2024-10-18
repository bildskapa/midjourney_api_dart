import 'dart:convert';

/// A class responsible for validating and decoding authentication tokens.
class TokenValidator {
  /// Creates an [TokenValidator].
  const TokenValidator();

  /// Validates and decodes the provided [token].
  ///
  /// The token is expected to be in JWT format. It first decodes the outer token
  /// and validates that it contains an expected Firebase structure.
  /// If valid, it further decodes the inner `idToken` and returns a [DecodedAuthTokenV3I] object.
  ///
  /// Throws an [InvalidTokenException] if the token is invalid or improperly formatted.
  ///
  /// [token] - The JWT token to be validated and decoded.
  DecodedAuthTokenV3I validateAndDecodeAuthTokenV3I(String token) {
    try {
      final outerToken = _decodeJWTToken(token);

      if (outerToken
          case {
            'midjourney_id': final String midjourneyId,
            'iat': final int iat,
            'exp': final int exp,
          }) {
        return DecodedAuthTokenV3I(
          midjourneyId: midjourneyId,
          iat: DateTime.fromMillisecondsSinceEpoch(iat * 1000),
          exp: DateTime.fromMillisecondsSinceEpoch(exp * 1000),
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
      final decodedToken = _decodeJWTToken(token);

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
  Map<String, Object?> _decodeJWTToken(String token) {
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
class DecodedAuthTokenV3I {
  /// The refresh token, used to obtain new authentication tokens.
  final String midjourneyId;

  /// The issued-at time (iat) of the token, represented as a [DateTime].
  final DateTime iat;

  /// The expiration time (exp) of the token, represented as a [DateTime].
  final DateTime exp;

  /// Creates a [DecodedAuthTokenV3I] with the provided attributes.
  DecodedAuthTokenV3I({
    required this.midjourneyId,
    required this.iat,
    required this.exp,
  });
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
