# Cara Menjalankan Victoria Sekuritas (Lokal)

Panduan menjalankan seluruh komponen di komputer lokal untuk demo/development.
Ada 2 cara: **A) Manual per komponen** (paling jelas) atau **B) Docker Compose** (sekali jalan).

Port yang dipakai (lokal):
| Komponen | URL |
|---|---|
| `sekuritas-api` (Laravel) | http://localhost:8000 |
| `sekuritas-ai` (FastAPI) | http://localhost:8001 |
| `sekuritas-frontend` (web depan) | http://localhost:3000 |
| `sekuritas-cms` (admin) | http://localhost:3001 |

---

## Prasyarat
- **PHP 8.2+** & **Composer**
- **PostgreSQL 14+** (buat database kosong, mis. `victoria`)
- **Node.js 18/20+** & **npm**
- **Python 3.11+** (untuk `sekuritas-ai`)
- **Flutter 3+** (opsional, untuk mobile)
- (Opsional) **Docker + Docker Compose** untuk cara B

---

## A) Manual per komponen

### 1. Backend — `sekuritas-api` (WAJIB pertama)
```bash
cd sekuritas-api
composer install
cp .env.example .env
php artisan key:generate
php artisan jwt:secret        # generate secret JWT (tymon/jwt-auth)
```
Edit `.env` bagian database (sesuaikan dgn PostgreSQL kamu):
```
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=victoria
DB_USERNAME=postgres
DB_PASSWORD=postgres

FILESYSTEM_DISK=public
MAIL_MAILER=log                # email masuk ke storage/logs (tanpa SMTP)
EKYC_PROVIDER=stub             # stub = eKYC jalan tanpa server AI
FRONTEND_URL=http://localhost:3000
```
Lalu migrasi + seed data demo + storage link + jalankan:
```bash
php artisan migrate:fresh --seed
php artisan storage:link
php artisan serve --port=8000
```
Cek: http://localhost:8000/api/health → `{"status":"ok"}`

**Akun hasil seed:**
- Admin CMS: `admin@sekuritas-demo.id` / `Admin@123456`
- Ops CMS: `ops@sekuritas-demo.id` / `Ops@123456`
- Nasabah (10 orang), password semua: `Nasabah@123` (mis. `budi.santoso@mail.test`)

### 2. Web depan — `sekuritas-frontend`
```bash
cd sekuritas-frontend
npm install                    # termasuk tesseract.js (OCR KTP gratis)
```
Buat file `.env`:
```
NUXT_PUBLIC_API_BASE=http://localhost:8000/api
```
Jalankan:
```bash
npm run dev                    # http://localhost:3000
```

### 3. CMS admin — `sekuritas-cms`
```bash
cd sekuritas-cms
npm install
```
Buat file `.env`:
```
NUXT_PUBLIC_API_BASE=http://localhost:8000/api/cms
NUXT_PUBLIC_FRONTEND_BASE=http://localhost:3000
```
Jalankan di port 3001 (agar tidak bentrok dgn web depan):
```bash
npm run dev -- --port 3001     # http://localhost:3001  → login pakai akun admin di atas
```

### 4. AI eKYC — `sekuritas-ai` (opsional; hanya perlu jika `EKYC_PROVIDER=fastapi`)
> Default `sekuritas-api` memakai `EKYC_PROVIDER=stub`, jadi langkah ini boleh dilewati untuk demo.
```bash
cd sekuritas-ai
python -m venv .venv && source .venv/bin/activate     # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env           # set EKYC_AI_API_KEY=rahasia123
uvicorn app.main:app --reload --port 8001
```
Cek: http://localhost:8001/health
Lalu aktifkan di `sekuritas-api/.env`:
```
EKYC_PROVIDER=fastapi
EKYC_FASTAPI_URL=http://localhost:8001
EKYC_FASTAPI_KEY=rahasia123
```
`php artisan config:clear` lalu jalankan ulang `php artisan serve`.

### 5. Mobile — `sekuritas-mobile` (opsional)
Base URL API di-set lewat `--dart-define=API_BASE=...` (default sudah `https://api.hamztech.my.id/api`).
```bash
cd sekuritas-mobile
flutter pub get

# Android emulator → localhost komputer = 10.0.2.2
flutter run --dart-define=API_BASE=http://10.0.2.2:8000/api

# iOS simulator
flutter run --dart-define=API_BASE=http://localhost:8000/api

# Pakai backend online (tanpa flag → pakai default hamztech):
flutter run
```
Build APK rilis:
```bash
flutter build apk --release --dart-define=API_BASE=https://api.hamztech.my.id/api
# hasil: build/app/outputs/flutter-apk/app-release.apk
```

---

## B) Docker Compose (sekali jalan)
Dari folder `sekuritas/` (root, tempat `docker-compose.yml`):
```bash
docker compose up -d --build
```
Ini menyalakan postgres, redis, minio, api, ekyc-ai, frontend, cms.
Setelah container `api` naik, jalankan migrasi + seed:
```bash
docker compose exec api php artisan migrate:fresh --seed
docker compose exec api php artisan storage:link
```
Akses: web http://localhost:3000, cms http://localhost:3001, api http://localhost:8080
(port di compose bisa disesuaikan di `docker-compose.yml`).

---

## Alur demo yang bisa dicoba
1. **Web depan** (`:3000`): lihat Home, Produk (filter + detail + grafik NAV), **Bandingkan**, **Promo**, Artikel.
2. **Daftar**: `/register` (OTP demo `123456`) → buat PIN. Coba juga lewat link promo `/promo/<KODE>` → cek badge referral.
3. **eKYC**: login → `/pembukaan-rekening/ekyc` → ambil foto KTP (OCR gratis on-device auto-isi NIK/Nama) → selfie → tanda tangan → verifikasi (lihat skor & keputusan).
4. **CMS** (`:3001`): login admin → menu **Event & Promo** (buat event, salin link referral, lihat leaderboard, export CSV), **KYC** (lihat panel skor eKYC + approve/reject), Produk, Artikel.
5. **Email**: karena `MAIL_MAILER=log`, isi email aktivasi/lengkapi-akun muncul di `sekuritas-api/storage/logs/laravel.log`.

## Troubleshooting singkat
- **401 di web/CMS** → token kadaluarsa; login ulang. Pastikan `NUXT_PUBLIC_API_BASE` benar.
- **CORS** → cek `config/cors.php` di api (default mengizinkan; sesuaikan origin bila perlu).
- **Port bentrok** → ubah `--port` Nuxt atau `--port` artisan serve.
- **Migrasi gagal** → pastikan database `victoria` sudah dibuat & kredensial `.env` benar.
- **Seed ulang** → `php artisan migrate:fresh --seed` (menghapus & isi ulang data demo).
