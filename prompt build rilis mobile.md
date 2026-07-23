# PROMPT — Build & Rilis Aplikasi Mobile Victoria Sekuritas (Flutter)

> Untuk membangun APK/AAB siap distribusi + upload ke Play Store. Repo: `sekuritas-mobile`.

## Prasyarat
- Flutter SDK terpasang (`flutter doctor` hijau), Android SDK/JDK.
- Sudah `flutter pub get`.
- Base URL API produksi: `https://api.hamztech.my.id/api` (atau domain final Victoria).

## B-1 — Ikon launcher (logo Victoria)
```
1. Ganti assets/images/logo.png dengan versi hi-res (min 512x512, transparan) — file
   saat ini 64x64 (akan buram bila dipakai langsung sebagai ikon).
2. flutter pub get
3. dart run flutter_launcher_icons     # config sudah ada di pubspec.yaml
4. Verifikasi ikon di android/app/src/main/res/mipmap-* dan iOS AppIcon.
```

## B-2 — Signing keystore (Android)
```
1. Buat keystore (SEKALI saja, SIMPAN AMAN — kalau hilang tak bisa update app):
   keytool -genkey -v -keystore ~/victoria-release.jks -keyalg RSA -keysize 2048 \
     -validity 10000 -alias victoria
2. Buat android/key.properties (JANGAN commit ke git):
   storePassword=<...>
   keyPassword=<...>
   keyAlias=victoria
   storeFile=/absolute/path/victoria-release.jks
3. Di android/app/build.gradle: load key.properties + set signingConfigs.release,
   dan buildTypes.release.signingConfig = signingConfigs.release.
   Pastikan android/.gitignore memuat key.properties & *.jks.
```

## B-3 — Build
```
# APK (bagi manual / sideload):
flutter build apk --release --dart-define=API_BASE=https://api.hamztech.my.id/api
# hasil: build/app/outputs/flutter-apk/app-release.apk

# App Bundle (WAJIB untuk Play Store):
flutter build appbundle --release --dart-define=API_BASE=https://api.hamztech.my.id/api
# hasil: build/app/outputs/bundle/release/app-release.aab
```

## B-4 — Rilis ke Google Play
```
1. Daftar akun Google Play Console (biaya sekali ~$25) — milik klien/Victoria.
2. Buat app baru → isi listing (nama "Victoria Sekuritas", ikon, screenshot, deskripsi,
   kebijakan privasi URL, kategori Finance).
3. Karena aplikasi keuangan: siapkan Data safety form, dan kemungkinan verifikasi
   Financial features (izin OJK / dokumen legal).
4. Upload app-release.aab ke track Internal testing dulu → lalu Production.
5. Play App Signing: aktifkan (Google kelola signing key upload).
```

## B-5 — iOS (opsional, butuh Mac + akun Apple Developer)
```
flutter build ipa --release --dart-define=API_BASE=https://api.hamztech.my.id/api
# lalu upload via Xcode/Transporter ke App Store Connect. Butuh Apple Developer ($99/thn).
```

## Catatan
- `--dart-define=API_BASE` menentukan backend yang dipakai build; tanpa flag = default di kode.
- Simpan keystore & password di tempat aman (password manager). Kehilangan = tak bisa update app di Play.
- Kepatuhan: aplikasi investasi butuh kelengkapan legal (izin OJK, kebijakan privasi, T&C) sebelum publik.
