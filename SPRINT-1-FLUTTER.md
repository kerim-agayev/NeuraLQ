# SPRINT-1-FLUTTER.md — NeuralQ Flutter Uygulaması (Sıfırdan)

> **DURUM**: Backend API tamamen hazır ve çalışıyor (Port 3000). Admin panel hazır (Port 3001). React Native versiyonu 9 sprint'te tamamlandı. Şimdi aynı uygulamayı Flutter ile sıfırdan yazıyoruz.
>
> **BACKEND DEĞİŞMİYOR** — Tek bir endpoint bile değiştirmiyoruz. Flutter sadece mevcut API'ye bağlanıyor.
>
> **API BASE URL**: `http://192.168.100.37:3000/api` (LAN dev) — Port 3000!
>
> **DOKÜMANLAR**: Bu dosyada ihtiyacın olan HER ŞEY var. Başka dosyaya bakma.

---

## PROJE KURULUMU

### Yeni Flutter Projesi

```bash
# Masaüstünde yeni klasör
flutter create neuralq_flutter --org com.neuralq --platforms android,ios
cd neuralq_flutter
```

### pubspec.yaml Bağımlılıkları

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.0

  # HTTP & API
  dio: ^5.4.0

  # Local Storage
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0

  # Navigation
  go_router: ^14.0.0

  # i18n
  easy_localization: ^3.0.0

  # Google Auth
  google_sign_in: ^6.2.0

  # Charts
  fl_chart: ^0.68.0

  # UI
  auto_size_text: ^3.0.0
  shimmer: ^3.0.0
  fluttertoast: ^8.2.0

  # Share & PDF
  share_plus: ^9.0.0
  pdf: ^3.10.0
  printing: ^5.12.0

  # Utils
  intl: ^0.19.0
  cached_network_image: ^3.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

```bash
flutter pub get
```

### Dosya Yapısı

```
lib/
├── main.dart
├── app.dart                          # MaterialApp + GoRouter + Riverpod
│
├── config/
│   ├── api_client.dart               # Dio + interceptors + token refresh
│   ├── router.dart                   # GoRouter routes
│   ├── theme.dart                    # Cyberpunk + Clean tema
│   └── constants.dart                # API_URL, timeouts
│
├── models/
│   ├── user.dart                     # User, Badge, AuthResponse
│   ├── question.dart                 # TestQuestion, QuestionOption
│   ├── result.dart                   # TestResult, StartTestResponse, AnswerResponse
│   ├── leaderboard.dart              # LeaderboardEntry
│   └── daily.dart                    # DailyChallenge, DailyAttemptResponse, DailyStats
│
├── providers/
│   ├── auth_provider.dart            # Auth state (user, tokens, login, register, logout)
│   ├── test_provider.dart            # Test session (questions, answers, streak)
│   ├── settings_provider.dart        # Theme, language
│   ├── leaderboard_provider.dart
│   └── daily_provider.dart
│
├── services/
│   ├── auth_service.dart             # register, login, googleAuth, getMe, updateProfile, refresh
│   ├── test_service.dart             # startTest, submitAnswer, completeTest, getResult, getHistory
│   ├── leaderboard_service.dart      # getGlobal, getCountry, getUserRank
│   ├── daily_service.dart            # getToday, submitAttempt, getStats
│   └── storage_service.dart          # Secure storage wrapper (tokens, onboarding, language)
│
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart    # 3 slide + dil seçimi
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── tabs/
│   │   ├── main_tabs.dart            # BottomNavigationBar scaffold
│   │   ├── home_screen.dart
│   │   ├── leaderboard_screen.dart
│   │   └── profile_screen.dart
│   ├── test/
│   │   ├── select_mode_screen.dart
│   │   ├── session_screen.dart       # Soru kartları + timer + options
│   │   └── result_screen.dart
│   ├── daily/
│   │   └── daily_screen.dart
│   └── history/
│       └── history_detail_screen.dart
│
├── widgets/
│   ├── ui/
│   │   ├── neon_text.dart            # Glow efektli text
│   │   ├── neon_button.dart          # Gradient + glow buton
│   │   ├── glass_card.dart           # Glassmorphism kart
│   │   ├── brain_loader.dart         # Loading overlay (beyin + daire + spinner)
│   │   └── skeleton_loader.dart      # Shimmer placeholder
│   ├── home/
│   │   ├── stats_row.dart
│   │   ├── quick_test_button.dart
│   │   ├── daily_challenge_card.dart
│   │   └── last_result_card.dart
│   ├── test/
│   │   ├── question_card.dart
│   │   ├── text_options.dart
│   │   ├── image_options.dart
│   │   ├── mixed_options.dart
│   │   ├── timer_bar.dart            # Daralan renkli bar (saniye YOK)
│   │   ├── progress_indicator.dart
│   │   ├── streak_counter.dart
│   │   └── answer_feedback.dart
│   ├── results/
│   │   ├── iq_reveal.dart            # Animated counter 0→IQ
│   │   ├── spider_chart.dart         # 5 kategori radar (fl_chart)
│   │   ├── celebrity_match.dart
│   │   ├── cognitive_age.dart
│   │   ├── category_breakdown.dart
│   │   └── share_card.dart
│   ├── profile/
│   │   ├── profile_header.dart
│   │   ├── badges_section.dart
│   │   ├── daily_stats_section.dart
│   │   ├── test_history.dart
│   │   ├── settings_section.dart
│   │   ├── edit_profile_modal.dart
│   │   └── language_picker_modal.dart  # Dropdown + arama
│   ├── leaderboard/
│   │   ├── leaderboard_list.dart
│   │   └── leaderboard_card.dart
│   └── badges/
│       └── badge_unlock_modal.dart
│
├── i18n/
│   ├── en.json
│   ├── tr.json
│   ├── az.json
│   ├── ru.json
│   ├── zh.json
│   ├── es.json
│   ├── hi.json
│   ├── ar.json
│   ├── pt.json
│   ├── fr.json
│   ├── de.json
│   ├── ja.json
│   ├── ko.json
│   ├── it.json
│   ├── pl.json
│   └── id.json
│
├── constants/
│   ├── languages.dart                # 16 dil + "Other"
│   ├── countries.dart                # 45+ ülke
│   ├── celebrities.dart              # IQ → celebrity match
│   └── badges.dart                   # 13 badge tanımı (emoji, title, description)
│
└── utils/
    └── formatters.dart               # Sayı, tarih formatları
```

---

## ADIMLAR (Sırayla Uygula)

### ADIM 1: Proje + Config + Tema

```dart
// config/constants.dart
const String apiBaseUrl = 'http://192.168.100.37:3000/api'; // Port 3000!
const Duration apiTimeout = Duration(seconds: 30);
```

```dart
// config/theme.dart
class AppTheme {
  // Cyberpunk (varsayılan)
  static ThemeData cyberpunk = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF0A0A0F),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00F5FF),       // Cyan neon
      secondary: Color(0xFFBF00FF),     // Purple
      error: Color(0xFFFF073A),
      surface: Color(0xFF12121A),
    ),
    // ... fonts, card theme, vb.
  );

  // Clean (açık tema)
  static ThemeData clean = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF8B5CF6),
      error: Color(0xFFEF4444),
      surface: Color(0xFFFFFFFF),
    ),
  );
}
```

```dart
// config/api_client.dart — Dio + Token interceptor + Auto refresh
// FLUTTER-AUTH-CONTRACT.md'deki Dio client kodunu AYNEN kullan
// Önemli: 401'de refresh, başarısızsa logout + login'e yönlendir
```

### ADIM 2: Models (Dart Classes)

```dart
// models/user.dart — FLUTTER-AUTH-CONTRACT.md'deki User, Badge, AuthResponse AYNEN
// models/question.dart — TestQuestion, QuestionOption
// models/result.dart — TestResult, StartTestResponse, AnswerResponse
// models/leaderboard.dart — LeaderboardEntry
// models/daily.dart — DailyChallenge, DailyAttemptResponse, DailyStats

// TÜM modeller fromJson constructor'a sahip olmalı
// Backend response formatı: { success: true, data: T }
// Her zaman response['data'] kullan
```

### ADIM 3: Services (API Çağrıları)

```dart
// services/auth_service.dart
class AuthService {
  final Dio dio;
  AuthService(this.dio);

  Future<AuthResponse> register({...}) async {
    final res = await dio.post('/auth/register', data: {...});
    return AuthResponse.fromJson(res.data['data']);
  }

  Future<AuthResponse> login({...}) async { ... }
  Future<AuthResponse> googleAuth(String idToken) async { ... }
  Future<User> getMe() async { ... }
  Future<User> updateProfile(Map<String, dynamic> data) async { ... }
}

// services/test_service.dart
class TestService {
  Future<StartTestResponse> startTest(String mode, String language) async {
    final res = await dio.post('/tests/start', data: {
      'mode': mode, // "ARCADE" veya "FULL_ANALYSIS"
      'language': language, // "tr", "az", "en", vb.
    });
    return StartTestResponse.fromJson(res.data['data']);
  }

  Future<AnswerResponse> submitAnswer(String sessionId, {
    required String questionId,
    required int? selectedAnswer, // null = süre doldu
    required int responseTimeMs,
  }) async { ... }

  Future<TestResult> completeTest(String sessionId) async { ... }
  Future<TestResult> getResult(String sessionId) async { ... }
  Future<List<TestResult>> getHistory() async { ... }
}

// services/leaderboard_service.dart
// services/daily_service.dart
// Tüm endpoint'ler MOBILE-API-DOCS.md'de detaylı tanımlı
```

### ADIM 4: Providers (Riverpod)

```dart
// providers/auth_provider.dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  // ...
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._service) : super(AuthState.initial());
  final AuthService _service;

  Future<void> login(String email, String password) async { ... }
  Future<void> register({...}) async { ... }
  Future<void> googleAuth() async { ... }
  Future<bool> loadUser() async { ... } // Splash'te çağrılır
  Future<void> logout() async { ... }
}

// providers/test_provider.dart — startSession, recordAnswer, nextQuestion, reset
// providers/settings_provider.dart — theme toggle, language change
```

### ADIM 5: Navigation (GoRouter)

```dart
// config/router.dart
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (_, __, child) => MainTabs(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/test/select-mode', builder: (_, __) => const SelectModeScreen()),
      GoRoute(path: '/test/session', builder: (_, __) => const SessionScreen()),
      GoRoute(path: '/test/result', builder: (_, __) => const ResultScreen()),
      GoRoute(path: '/daily', builder: (_, __) => const DailyScreen()),
      GoRoute(path: '/history/:id', builder: (_, state) =>
        HistoryDetailScreen(id: state.pathParameters['id']!)),
    ],
  );
});
```

### ADIM 6: Splash + Onboarding + Auth Ekranları

```
Splash → token kontrol → home VEYA onboarding VEYA login
Onboarding → 3 slide + 16 dil seçici grid + "Get Started"
Login → email + password + Google buton + "Sign Up" link
Register → username + email + password + age + country picker + Google buton
```

### ADIM 7: Tab Navigation + Home

```
BottomNavigationBar: Home 🏠, Ranks 🏆, Profile 👤
Home: StatsRow + QuickTestButton + DailyChallengeCard + LastResultCard
```

### ADIM 8: Test Engine

```
SelectMode → ARCADE / FULL_ANALYSIS
Session → QuestionCard + TimerBar (saniye YOK, sadece bar) + Options + Streak
BrainLoader → tüm loading'lerde (overflow: hidden, beyin dairenin İÇİNDE)
Result → IQReveal + SpiderChart + CelebrityMatch + CognitiveAge + CategoryBreakdown
```

### ADIM 9: Leaderboard + Profile + Daily + History

```
Leaderboard: Global/Country tab + ListView + pull-to-refresh
Profile: Header + Badges grid + DailyStats + TestHistory + Settings
Daily: Soru kartı + sonuç + "Already done" durumu
History detail: IQ + spider chart + celebrity + ranks
```

### ADIM 10: i18n + Responsive + Polish

```
16 dil JSON dosyası
auto_size_text KULLAN — tüm değişken text'lerde
FittedBox KULLAN — container'a sığdırma
SafeArea HER YERDE
MediaQuery.of(context).size ile responsive boyutlar
```

---

## KRİTİK KURALLAR (React Native'den Öğrenilen Dersler)

### 1. BrainLoader — Beyin dairenin İÇİNDE olmalı

```dart
class BrainLoader extends StatelessWidget {
  final String message;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = (size.width * 0.28).clamp(80.0, 120.0);

    return Container(
      color: const Color(0xFF0A0A0F).withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Daire — beyin ve spinner BUNUN İÇİNDE
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00F5FF), width: 2),
              ),
              clipBehavior: Clip.hardEdge, // ← TAŞMAYI ENGELLE
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🧠', style: TextStyle(fontSize: circleSize * 0.28)),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: circleSize * 0.2,
                    height: circleSize * 0.2,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00F5FF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Text — dairenin DIŞINDA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AutoSizeText(
                message,
                maxLines: 2,
                minFontSize: 10,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF00F5FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Timer — Saniye YOK, sadece daralan bar

```dart
// widgets/test/timer_bar.dart
// Sadece renkli daralan bar göster
// Saniye text'i EKLEME — React Native'de sorun çıkardı
// Renk: yeşil(100-60%) → sarı(60-30%) → turuncu(30-10%) → kırmızı(10-0%)
```

### 3. Tüm Text'lerde AutoSizeText

```dart
// React Native'de en büyük sorun uzun dil metinleriydi
// Flutter'da HER değişken text'te AutoSizeText kullan:
AutoSizeText(
  'Пространственное мышление',  // Rusça uzun kelime
  maxLines: 1,
  minFontSize: 8,
  style: TextStyle(fontSize: 13),
)
```

### 4. Tab Bar — SafeArea + minimum padding

```dart
// BottomNavigationBar'da:
SafeArea(
  child: BottomNavigationBar(
    // Android sistem butonlarıyla çakışma olmasın
  ),
)
// VEYA Scaffold'da: bottomNavigationBar zaten SafeArea içerir
```

### 5. StatsRow label'ları KISA

```dart
// BP, NC gibi kısaltmalar kullan — uzun kelimeler taşar
// i18n'de: "stats.bp": "BP", "stats.nc": "NC", "stats.rank": "Rank"
```

### 6. Profile Edit header — Flex layout

```dart
Row(
  children: [
    TextButton(onPressed: cancel, child: AutoSizeText(t('cancel'), maxLines: 1, minFontSize: 10)),
    Expanded(child: AutoSizeText(t('editProfile'), textAlign: TextAlign.center, maxLines: 1, minFontSize: 10)),
    TextButton(onPressed: save, child: AutoSizeText(t('save'), maxLines: 1, minFontSize: 10, style: TextStyle(color: cyan))),
  ],
)
```

### 7. Language picker — Dropdown modal (cycle DEĞİL)

```dart
// Tek tek tıklayarak dil değiştirmek YERİNE:
// Modal bottom sheet + ListView + arama kutusu
// 16 dil + "Other Language" seçeneği
```

---

## BACKEND API ÖZETİ

| Endpoint | Method | Açıklama |
|----------|--------|----------|
| `/api/auth/register` | POST | Kayıt |
| `/api/auth/login` | POST | Giriş |
| `/api/auth/google` | POST | Google OAuth ({ idToken }) |
| `/api/auth/me` | GET | Profil bilgisi |
| `/api/auth/me` | PATCH | Profil güncelle |
| `/api/auth/refresh` | POST | Token yenile |
| `/api/tests/start` | POST | Test başlat ({ mode, language }) |
| `/api/tests/{id}/answer` | POST | Cevap gönder |
| `/api/tests/{id}/complete` | POST | Testi bitir → IQ hesapla |
| `/api/tests/{id}/result` | GET | Sonuç detayı |
| `/api/tests/history` | GET | Geçmiş testler |
| `/api/results/{id}/certificate` | GET | PDF sertifika |
| `/api/leaderboard/global` | GET | Global top 100 |
| `/api/leaderboard/country/{code}` | GET | Ülke sıralaması |
| `/api/leaderboard/user/rank` | GET | Kullanıcının rankı |
| `/api/daily/today` | GET | Günün sorusu |
| `/api/daily/today/attempt` | POST | Daily cevap |
| `/api/daily/stats` | GET | Daily istatistikler |

**Port 3000! (3001 admin paneli, Flutter ASLA 3001'e bağlanmamalı)**

---

## ÖNEMLİ EDGE CASE'LER

1. **"other" dili** → backend'e `"en"` gönder (verbal İngilizce gelir)
2. **Desteklenmeyen dil** → backend `verbalSkipped: true` döner → Spider chart'ta "N/A"
3. **MEMORY = 0 soru** → backend otomatik LOGIC+SPEED'e dağıtır → mobilde MEMORY "N/A"
4. **Token expire** → 401'de refresh dene → başarısız → logout → login'e yönlendir
5. **Daily challenge yok** → "No challenge available today" göster
6. **Boş leaderboard** → "No rankings yet" empty state
7. **Boş test history** → "Take your first test!" empty state
8. **Test crash** → her cevap SharedPreferences'a backup → app restart'ta sor
9. **Android nav bar çakışması** → SafeArea + min 8px bottom padding
10. **Uzun dil metinleri** → AutoSizeText HER YERDE

---

## GOOGLE OAUTH (.env)

```
# Flutter'da environment variable yok, constants.dart kullan:
const String googleWebClientId = 'xxxx.apps.googleusercontent.com';
# VEYA --dart-define ile:
# flutter run --dart-define=GOOGLE_CLIENT_ID=xxxx
```

```dart
// google_sign_in kullanımı:
final GoogleSignIn _googleSignIn = GoogleSignIn(
  serverClientId: googleWebClientId,
);

Future<String?> getGoogleIdToken() async {
  final account = await _googleSignIn.signIn();
  if (account == null) return null;
  final auth = await account.authentication;
  return auth.idToken;
}
```

---

## BİTİRME KONTROL LİSTESİ

```
✅ PROJE KURULUMU
  ✅ flutter create + pub get
  ✅ Tüm paketler yüklü
  ✅ Dosya yapısı oluşturuldu
  ✅ Tema (Cyberpunk + Clean) çalışıyor

✅ AUTH
  ✅ Splash → token kontrol → doğru yönlendirme
  ✅ Onboarding (3 slide + 16 dil)
  ✅ Login (email + password + Google)
  ✅ Register (username + email + password + age + country)
  ✅ Token refresh interceptor
  ✅ Logout

✅ HOME
  ✅ StatsRow (kısa label'lar: BP, NC, Rank)
  ✅ QuickTestButton (pulsating animasyon)
  ✅ DailyChallengeCard
  ✅ LastResultCard
  ✅ "Welcome back, username" (username varsa)

✅ TEST ENGINE
  ✅ Mode seçimi (Arcade / Full)
  ✅ BrainLoader (beyin dairenin İÇİNDE, 3 loading'de kullanılıyor)
  ✅ QuestionCard + TextOptions/ImageOptions/MixedOptions
  ✅ TimerBar (sadece bar, saniye YOK)
  ✅ Progress indicator + Streak counter
  ✅ Doğru/yanlış feedback (haptic + animasyon)

✅ SONUÇ
  ✅ IQ reveal animasyonu
  ✅ Spider chart (fl_chart, 5 kategori, verbalSkipped → N/A)
  ✅ Celebrity match
  ✅ Cognitive age
  ✅ Category breakdown (AutoSizeText ile kısa label'lar)
  ✅ Share + Certificate butonları

✅ LEADERBOARD
  ✅ Global / Country tab
  ✅ Pull-to-refresh
  ✅ Kullanıcı highlight

✅ PROFILE
  ✅ Header (BP, NC, Streak)
  ✅ Badges grid (kazanılmış + kilitli)
  ✅ Badge unlock modal (animasyonlu)
  ✅ Daily stats
  ✅ Test history
  ✅ Settings (tema toggle, dil DROPDOWN MODAL, logout)
  ✅ Edit profile (Flex header — İptal/Başlık/Kaydet responsive)

✅ DAILY
  ✅ Günün sorusu
  ✅ Cevaplama + sonuç
  ✅ "Already done" durumu
  ✅ Badge kazanım bildirimi

✅ i18n
  ✅ 16 dil JSON dosyası
  ✅ easy_localization çalışıyor

✅ RESPONSIVE
  ✅ AutoSizeText tüm değişken text'lerde
  ✅ BrainLoader responsive (overflow: hidden)
  ✅ SafeArea tüm ekranlarda
  ✅ Tab bar Android nav bar ile çakışma YOK
  ✅ EN, RU, TR, AZ dillerinde test edildi

✅ DERLEME
  ✅ flutter analyze → 0 hata
  ✅ flutter run → çalışıyor
```
