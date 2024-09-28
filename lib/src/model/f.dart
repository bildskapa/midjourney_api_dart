class MidjourneyF {
  const MidjourneyF({
    required this.mode,
    required this.private,
  });

  final MidjourneyMode mode;
  final bool private;
}

enum MidjourneyMode {
  relaxed,
}
