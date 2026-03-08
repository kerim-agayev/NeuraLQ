class AppLanguage {
  final String code;
  final String name;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.flag,
  });
}

const List<AppLanguage> appLanguages = [
  AppLanguage(code: 'en', name: 'English', flag: '\u{1F1EC}\u{1F1E7}'),
  AppLanguage(code: 'tr', name: 'T\u00FCrk\u00E7e', flag: '\u{1F1F9}\u{1F1F7}'),
  AppLanguage(code: 'az', name: 'Az\u0259rbaycanca', flag: '\u{1F1E6}\u{1F1FF}'),
  AppLanguage(code: 'ru', name: '\u0420\u0443\u0441\u0441\u043A\u0438\u0439', flag: '\u{1F1F7}\u{1F1FA}'),
  AppLanguage(code: 'zh', name: '\u4E2D\u6587', flag: '\u{1F1E8}\u{1F1F3}'),
  AppLanguage(code: 'es', name: 'Espa\u00F1ol', flag: '\u{1F1EA}\u{1F1F8}'),
  AppLanguage(code: 'hi', name: '\u0939\u093F\u0928\u094D\u0926\u0940', flag: '\u{1F1EE}\u{1F1F3}'),
  AppLanguage(code: 'ar', name: '\u0627\u0644\u0639\u0631\u0628\u064A\u0629', flag: '\u{1F1F8}\u{1F1E6}'),
  AppLanguage(code: 'pt', name: 'Portugu\u00EAs', flag: '\u{1F1E7}\u{1F1F7}'),
  AppLanguage(code: 'fr', name: 'Fran\u00E7ais', flag: '\u{1F1EB}\u{1F1F7}'),
  AppLanguage(code: 'de', name: 'Deutsch', flag: '\u{1F1E9}\u{1F1EA}'),
  AppLanguage(code: 'ja', name: '\u65E5\u672C\u8A9E', flag: '\u{1F1EF}\u{1F1F5}'),
  AppLanguage(code: 'ko', name: '\uD55C\uAD6D\uC5B4', flag: '\u{1F1F0}\u{1F1F7}'),
  AppLanguage(code: 'it', name: 'Italiano', flag: '\u{1F1EE}\u{1F1F9}'),
  AppLanguage(code: 'pl', name: 'Polski', flag: '\u{1F1F5}\u{1F1F1}'),
  AppLanguage(code: 'id', name: 'Indonesia', flag: '\u{1F1EE}\u{1F1E9}'),
];

// Languages that support verbal questions
const List<String> verbalSupportedLanguages = [
  'en', 'tr', 'az', 'ru', 'zh', 'es', 'hi', 'ar', 'pt', 'fr', 'de', 'ja',
  'ko', 'it', 'pl', 'id',
];
