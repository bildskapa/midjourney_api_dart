/// Represents a function in the Midjourney API.
///
/// This class holds the mode and privacy status of a function.
///
/// Example usage:
/// ```dart
/// final function = MidjourneyFunction(
///   mode: MidjourneyMode.relaxed,
///   private: true,
/// );
/// ```
///
/// Properties:
/// - `mode` (MidjourneyMode): The mode of the function.
/// - `private` (bool): Whether the function is private or not.
///
/// Methods:
/// - `toJson()`: Converts the object to a JSON-encodable map.
class MidjourneyFunction {
  const MidjourneyFunction({
    required this.mode,
    required this.private,
  });

  /// The mode of the function.
  final MidjourneyMode mode;

  /// Whether the function is private or not.
  final bool private;

  /// Converts the object to a JSON-encodable map.
  Map<String, Object?> toJson() => {
        'mode': mode.value,
        'private': private,
      };
}

/// Represents the mode of a Midjourney function.
enum MidjourneyMode {
  fast._('fast'),
  relaxed._('relaxed');

  final String value;

  const MidjourneyMode._(this.value);
}
