class MidjourneyF {
  const MidjourneyF({
    required this.mode,
    required this.private,
  });

  final MidjourneyMode mode;
  final bool private;

  /// Converts the object to a JSON-encodable map.
  Map<String, Object?> toJson() => {
        'mode': mode.value,
        'private': private,
      };
}

enum MidjourneyMode {
  relaxed._('relaxed');

  final String value;

  const MidjourneyMode._(this.value);
}
