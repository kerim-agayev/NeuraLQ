class CelebrityMatch {
  final String key;
  final String label;
  final String emoji;
  final int minIq;
  final int maxIq;

  const CelebrityMatch({
    required this.key,
    required this.label,
    required this.emoji,
    required this.minIq,
    required this.maxIq,
  });
}

const List<CelebrityMatch> celebrityMatches = [
  CelebrityMatch(key: 'goldfish', label: 'A Goldfish', emoji: '\u{1F420}', minIq: 55, maxIq: 75),
  CelebrityMatch(key: 'patrick_star', label: 'Patrick Star', emoji: '\u{2B50}', minIq: 76, maxIq: 85),
  CelebrityMatch(key: 'homer_simpson', label: 'Homer Simpson', emoji: '\u{1F369}', minIq: 86, maxIq: 95),
  CelebrityMatch(key: 'average_joe', label: 'An Average Human', emoji: '\u{1F9D1}', minIq: 96, maxIq: 105),
  CelebrityMatch(key: 'hermione', label: 'Hermione Granger', emoji: '\u{1F4DA}', minIq: 106, maxIq: 115),
  CelebrityMatch(key: 'tony_stark', label: 'Tony Stark', emoji: '\u{1F9BE}', minIq: 116, maxIq: 125),
  CelebrityMatch(key: 'sherlock', label: 'Sherlock Holmes', emoji: '\u{1F50D}', minIq: 126, maxIq: 139),
  CelebrityMatch(key: 'rick_sanchez', label: 'Rick Sanchez', emoji: '\u{1F9EA}', minIq: 140, maxIq: 159),
  CelebrityMatch(key: 'doc_manhattan', label: 'Dr. Manhattan', emoji: '\u{1F535}', minIq: 160, maxIq: 195),
];

CelebrityMatch getCelebrityByKey(String key) {
  return celebrityMatches.firstWhere(
    (c) => c.key == key,
    orElse: () => celebrityMatches[3], // average_joe
  );
}

CelebrityMatch getCelebrityByIq(int iq) {
  return celebrityMatches.firstWhere(
    (c) => iq >= c.minIq && iq <= c.maxIq,
    orElse: () => iq > 195 ? celebrityMatches.last : celebrityMatches.first,
  );
}
