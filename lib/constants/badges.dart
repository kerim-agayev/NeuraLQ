class BadgeInfo {
  final String key;
  final String title;
  final String description;
  final String emoji;

  const BadgeInfo({
    required this.key,
    required this.title,
    required this.description,
    required this.emoji,
  });
}

const List<BadgeInfo> allBadges = [
  BadgeInfo(key: 'first_test', title: 'First Steps', description: 'Complete your first test', emoji: '\u{1F476}'),
  BadgeInfo(key: 'test_5', title: 'Getting Serious', description: 'Complete 5 tests', emoji: '\u{1F4AA}'),
  BadgeInfo(key: 'test_25', title: 'Test Veteran', description: 'Complete 25 tests', emoji: '\u{1F3C6}'),
  BadgeInfo(key: 'iq_120', title: 'Sharp Mind', description: 'Score 120+ IQ', emoji: '\u{1F9E0}'),
  BadgeInfo(key: 'iq_140', title: 'Genius Level', description: 'Score 140+ IQ', emoji: '\u{1F31F}'),
  BadgeInfo(key: 'iq_160', title: 'Off The Charts', description: 'Score 160+ IQ', emoji: '\u{1F680}'),
  BadgeInfo(key: 'streak_7', title: 'Weekly Warrior', description: '7-day daily challenge streak', emoji: '\u{1F525}'),
  BadgeInfo(key: 'streak_30', title: 'Monthly Master', description: '30-day daily challenge streak', emoji: '\u{26A1}'),
  BadgeInfo(key: 'logic_master', title: 'Logic Master', description: 'Logic percentile 95+', emoji: '\u{2699}\u{FE0F}'),
  BadgeInfo(key: 'spatial_master', title: 'Spatial Master', description: 'Spatial percentile 95+', emoji: '\u{1F441}\u{FE0F}'),
  BadgeInfo(key: 'speed_master', title: 'Speed Demon', description: 'Speed percentile 95+', emoji: '\u{23F1}\u{FE0F}'),
  BadgeInfo(key: 'top_100', title: 'Elite 100', description: 'Global rank top 100', emoji: '\u{1F451}'),
  BadgeInfo(key: 'country_1', title: 'National Champion', description: 'Rank #1 in your country', emoji: '\u{1F3C5}'),
];

BadgeInfo getBadgeInfo(String key) {
  return allBadges.firstWhere(
    (b) => b.key == key,
    orElse: () => BadgeInfo(key: key, title: key, description: '', emoji: '\u{1F3C5}'),
  );
}
