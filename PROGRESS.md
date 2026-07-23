# PROGRESS — Victoria Sekuritas (handoff untuk lanjut di Claude free)

Update terakhir: 2026-07-22 (sesi lanjutan). Mencatat **sudah sampai mana** + **prompt siap-pakai** untuk melanjutkan. Semua perubahan sudah **di-commit & push ke `main`** tiap repo (auto-deploy).

Repo lokal: `sekuritas-api` (Laravel), `sekuritas-cms` (Nuxt admin), `sekuritas-frontend` (Nuxt web depan), `sekuritas-mobile` (Flutter), `sekuritas-ai` (FastAPI eKYC — commit lokal, **belum ada repo GitHub**).

> **Design system FINAL = warna brand ASLI Victoria** dari logo: **MERAH `#A40001`** + netral hangat (krem `#F0F3EC`, rose `#C67177`/`#D59997`, `#FFFDFC`/`#E2DAD3`/`#D2D7D3`), teks `#1A1A1A`. Gradient hero `#7D0001→#A40001→#C67177`. Dipakai konsisten di web, CMS, mobile, & email. (Palet navy/emas & Indigo Premium = lama, tidak dipakai.)

---

## ✅ SELESAI (sesi 1 — modul eKYC & email)
`sekuritas-api`: modul eKYC lengkap (migrasi `ekyc_*`, model, adapter `EkycProvider`+Stub/FastApi+Manager, `EkycService` OCR→liveness→face-match→verify + anti-fraud, `SignatureService` canvas/Privy, `EkycController` + route `/api/ekyc/*`, `config/ekyc.php`). Template email Victoria (`RegistrationMail`, `CompleteAccountMail` + Blade). Scaffold `sekuritas-ai` (FastAPI stub OCR/liveness/face-match + Docker).

## ✅ SELESAI (sesi 2 — data, integrasi, rebrand)
- **Seeder data demo** (`sekuritas-api`): `ArticleSeeder` (12 artikel), `NasabahSeeder` (10 nasabah + KYC status bervariasi + risk profile + sesi eKYC lengkap + SID + portofolio + transaksi), `EventRegistrationSeeder` (leaderboard). Dipanggil dari `DatabaseSeeder`. Password nasabah: `Nasabah@123`.
- **Registrasi web + aktivasi email** (`sekuritas-api`): `POST /auth/register-email` & `/auth/activate`, migrasi `activation_token`, kirim `RegistrationMail` saat daftar & `CompleteAccountMail` setelah eKYC verify (try/catch + log).
- **Feature test** eKYC happy-path (`tests/Feature/EkycFlowTest.php`, sqlite + Storage fake + JWT).
- **CMS**: rebrand ke Indigo Premium + panel **review hasil eKYC** di detail KYC (skor OCR/liveness/face + flags); backend `CmsKycController@show` menyertakan sesi eKYC.
- **Web depan**: composable `useEkyc.ts` + halaman **`/pembukaan-rekening/ekyc`** (stepper KTP→selfie→face-match→tanda tangan canvas→verifikasi, kamera via `capture`), + CTA di halaman KYC.
- **Web depan — Promo/Event**: `/promo` (list + empty-state) & `/promo/[kode]` (landing referral: belum login→`/register?ref=KODE`, login→`POST /events/register`) + link nav.
- **Mobile**: nama app → "Victoria Sekuritas" (warna Indigo Premium dipertahankan — memang disengaja).
- **docker-compose.yml** (root `sekuritas/`): orkestrasi postgres/redis/minio/api/ekyc-ai/frontend/cms.

## ✅ SELESAI (sesi 3 — referral, bandingkan, OCR gratis)
- **Referral loop lengkap**: `register.vue` membaca `?ref=KODE` → setelah daftar+login auto `POST /events/register` + badge promo di form.
- **Halaman Bandingkan** (`/bandingkan`): reksa dana & Manajer Investasi (pilih maks 3, tabel + bar CSS, tanpa dependency chart). Data `/api/products` & `/api/products/managers`. Nav ditambah.
- **OCR KTP GRATIS on-device**: composable `useKtpOcr` (Tesseract.js, parse NIK 16-digit + nama) di halaman eKYC → auto-isi & dikirim sbg override ke `/ekyc/ocr`. `tesseract.js` ditambah ke package.json (**perlu `npm i`**).
- **CMS Event & Promo** (`pages/events/index.vue`): list + create + **edit** (prefill via show, PUT) + toggle + hapus + **salin link referral** + **leaderboard modal** (GET `/cms/events/{id}/leaderboard`) + **export CSV** (GET `/cms/events/{id}/export`, blob) + menu sidebar. Melengkapi UI admin yang sebelumnya belum ada.
- **Brand text sweep**: semua teks "Sekuritas" → "Victoria Sekuritas" di web (logo/footer/judul/PT) & mobile (splash/notif/profil).
- **Tanda tangan digital pakai library resmi** (sesuai MASTER_PROMPT): web = **signature_pad** (szimek) di halaman eKYC (ganti canvas custom); mobile = package **signature** drawing pad di `signature_screen` (ganti upload foto). Perlu `npm i` / `flutter pub get`.
- **SID 2 langkah**: `approve KYC` tak lagi auto-terbitkan SID. Endpoint baru `POST /cms/kyc/{id}/issue-sid` + tombol **"Kirim ke S-INVEST"** di CMS (muncul setelah approved). Prompt integrasi asli: **`prompt integrasi s-invest.md`** (butuh kredensial KSEI + bank RDN dari klien).

## ✅ SELESAI (sesi 4 — hardening & adapter siap-produksi)
- **Warna + LOGO asli Victoria** (merah #A40001) di web/CMS/mobile/email + favicon (logo dari `design/asset+logo`).
- **CI/CD**: GitHub Actions di 5 repo (build/test/analyze).
- **Payment gateway adapter**: `PaymentGateway` contract + `MockGateway` + **`MidtransGateway`** (VA/QRIS, verifikasi signature SHA-512) + `config/payment.php`. Webhook kini verifikasi signature. Default `mock`.
- **S-INVEST adapter**: `SInvestService` jadi orchestrator + `MockProvider`/`KseiProvider`(skeleton) + `config/sinvest.php` + env RDN. Ganti via `SINVEST_DRIVER`.
- **Enkripsi file eKYC at-rest** (AES-256) via `EkycFileStore` + `EKYC_ENCRYPT_FILES` (default off).
- **P4**: halaman `/pembukaan-rekening/data` (Data Pribadi/Pekerjaan/Informasi Tambahan) → `POST /api/kyc/submit`.
- **Mobile**: `EkycApi` client (`/api/ekyc/*`) + config `flutter_launcher_icons`.
- **Dok baru**: `RISET_EKYC_OPEN_SOURCE.md`, `prompt build rilis mobile.md`, `prompt integrasi s-invest.md`, `prompt deploy server.md`, `CARA_MENJALANKAN.md`, `install-all.sh`.

## ✅ SELESAI (sesi 5 — item ⚠️ MASTER_PROMPT ditutup)
- **Model AI asli** (`sekuritas-ai`): `ocr/liveness/face_match` engine-aware (PaddleOCR/InsightFace/Silent-Face ONNX) + parser field KTP + fallback stub; `requirements-models.txt` (deps berat terpisah); `ServiceError`→status code.
- **Security**: rate-limit `throttle:10,1` (auth) & `throttle:30,1` (eKYC).
- **Adapter vendor eKYC**: skeleton **Sumsub/Veriff/ADVANCE.AI** + terdaftar di `EkycManager` + `config('ekyc.vendors')`.
- **Dokumen formal**: `SAD_TDD.md` (arsitektur+kontrak+sequence), `UIUX_RESEARCH.md` (Victoria vs CGS).
- Status per bagian ditandai di `PROMPTS.md` & `MASTER_PROMPT_EKYC...md`.

## ⏭️ Sisa (butuh kredensial/aksi klien atau run manual)
- **N-1 WAJIB**: `bash install-all.sh` → setup `sekuritas-api` → `migrate:fresh --seed` → jalankan (verifikasi end-to-end). Belum dijalankan di sini.
- Aktifkan integrasi ASLI (kredensial klien): Midtrans (`PAYMENT_GATEWAY=midtrans`), S-INVEST (`SINVEST_DRIVER=ksei`), Privy, model AI (`OCR_ENGINE=paddle` dst di `sekuritas-ai`).
- Mobile: ✅ **layar eKYC end-to-end sudah di-wire** (`EkycScreen` /kyc/ekyc: kamera+OCR+liveness+face+ttd+verify) + izin kamera Android/iOS. Sisa: generate ikon hi-res, build/rilis APK (`prompt build rilis mobile.md`).
- Enkripsi produksi: set `EKYC_ENCRYPT_FILES=true` + sajikan file via endpoint terproteksi (bukan URL publik).
- **Prompt DEPLOY `sekuritas-ai` ke server** dipisah ke file `prompt deploy server.md`.

## ⚠️ Belum dijalankan
- **`composer install` + `php artisan migrate --seed`** belum dijalankan di sesi ini (vendor/DB tak tersedia). WAJIB dilakukan sebelum tes.
- Auth mobile pakai OTP+PIN; register-email adalah jalur WEB terpisah — jangan bentrok.

---

## ⏭️ PROMPT LANJUTAN (siap-pakai)

### N-1 — Migrate, seed, jalankan test (WAJIB pertama)
```
Di sekuritas-api: composer install; copy .env.example ke .env; set DB PostgreSQL
(atau sqlite) + EKYC_PROVIDER=stub + MAIL_MAILER=log; php artisan key:generate;
php artisan migrate:fresh --seed; php artisan test --filter=EkycFlowTest.
Perbaiki bila ada error migrasi/seed (khususnya FK uuid ekyc_* di Postgres/sqlite).
Verifikasi data: 10 nasabah, artikel, event + leaderboard terisi. Commit bila ada fix.
```

### N-2 — (SELESAI) OCR on-device Tesseract.js — sisa hanya `npm i tesseract.js` lalu uji.

### N-3 — Repo GitHub sekuritas-ai + model nyata
```
Buat repo marfino3028/sekuritas-ai, push folder sekuritas-ai. Aktifkan model nyata
satu per satu (uncomment requirements + isi TODO): PaddleOCR (ocr.py), InsightFace
(face_match.py), Silent-Face-Anti-Spoofing (liveness.py). Uji tiap endpoint. Set
sekuritas-api EKYC_PROVIDER=fastapi + URL/KEY, uji end-to-end. Commit & push.
```

### N-4 — (SELESAI) referral `?ref=` di register.
### N-5 — (SELESAI) halaman Bandingkan reksadana & MI.

### N-6 — Grafik NAV pakai library (opsional, upgrade visual)
```
Di sekuritas-frontend produk/[id] & /bandingkan: ganti bar CSS dengan grafik garis
(chart.js / vue-chartjs, tambah ke package.json). Data GET /api/products/{id}/nav-history.
Referensi: design/home-kliktombolbelireksadana-detailreksadana.png. Commit & push.
```

### N-7 — (SELESAI) CMS Event & Promo (list/create/toggle/hapus/salin link).
### N-8 — (SELESAI) CMS event: edit + leaderboard + export + **upload banner** (`POST /cms/events/{id}/banner`).

> **Deploy ke server** dipisah ke file **`prompt deploy server.md`** (untuk dikirim ke Claude server). **Cara menjalankan lokal** ada di **`CARA_MENJALANKAN.md`**.

---

## Referensi
- Warna & brand: `ANALISA_DAN_DESIGN.md` (catat: sistem final = Indigo Premium).
- Peta asset → fitur & prompt build web P0–P18: `PROMPTS.md`.
- Arsitektur eKYC detail: `MASTER_PROMPT_EKYC_VICTORIA_SEKURITAS.md`.
- Proposal harga: `PROPOSAL_PENAWARAN.md`.
