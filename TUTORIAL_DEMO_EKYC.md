# Tutorial & Skrip Demo — Victoria Sekuritas (fokus eKYC)

Panduan langkah-demi-langkah untuk **merekam video demo**. Tiga peran: **Nasabah**, **Ops**, **Super Admin**. Alur inti: nasabah daftar → **eKYC** → data → transaksi; ops **review KYC + terbitkan SID**; super admin kelola semua.

> Mode demo: `EKYC_PROVIDER=stub`, `PAYMENT_GATEWAY=mock`, `SINVEST_DRIVER=mock`, `MAIL_MAILER=log`. Semua jalan tanpa kredensial pihak ketiga.

---

## 0. Persiapan sebelum rekaman

### 0a. CARA MENJALANKAN (dari nol) — lakukan sekali
> Butuh: PHP 8.2+, Composer, Node 18/20+, (opsional Python 3.11+ untuk AI). PostgreSQL **tidak wajib** — pakai SQLite biar cepat.

**1) Install semua dependency (1 perintah):**
```bash
cd /Users/user/Documents/freelance/sekuritas
bash install-all.sh
```

**2) Backend API** (`sekuritas-api`) — terminal 1:
```bash
cd sekuritas-api
cp .env.example .env
php artisan key:generate
php artisan jwt:secret --force
touch database/database.sqlite
```
Edit `.env` → set baris ini (hapus DB_HOST/PORT/USERNAME/PASSWORD bila ada):
```
DB_CONNECTION=sqlite
DB_DATABASE=/Users/user/Documents/freelance/sekuritas/sekuritas-api/database/database.sqlite
MAIL_MAILER=log
EKYC_PROVIDER=stub
PAYMENT_GATEWAY=mock
SINVEST_DRIVER=mock
FRONTEND_URL=http://localhost:3000
```
Lalu isi data demo + jalankan:
```bash
php artisan migrate:fresh --seed
php artisan storage:link
php artisan serve --port=8000
```
Cek: buka http://localhost:8000/api/health → `{"status":"ok"}`.

**3) Web depan** (`sekuritas-frontend`) — terminal 2:
```bash
cd sekuritas-frontend
echo "NUXT_PUBLIC_API_BASE=http://localhost:8000/api" > .env
npm run dev            # http://localhost:3000
```

**4) CMS admin** (`sekuritas-cms`) — terminal 3:
```bash
cd sekuritas-cms
printf "NUXT_PUBLIC_API_BASE=http://localhost:8000/api/cms\nNUXT_PUBLIC_FRONTEND_BASE=http://localhost:3000\n" > .env
npm run dev -- --port 3001    # http://localhost:3001
```

**5) AI eKYC (OPSIONAL)** — hanya jika mau OCR/liveness "nyata". Default `EKYC_PROVIDER=stub` sudah cukup:
```bash
cd sekuritas-ai
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env      # set EKYC_AI_API_KEY=rahasia123
uvicorn app.main:app --reload --port 8001
# lalu di sekuritas-api/.env: EKYC_PROVIDER=fastapi, EKYC_FASTAPI_URL=http://localhost:8001, EKYC_FASTAPI_KEY=rahasia123
```

> Kalau `migrate:fresh --seed` error → cek path SQLite di `.env` sudah absolut & benar. Detail & troubleshooting: `CARA_MENJALANKAN.md`.

### 0b. Service & URL (setelah jalan)
| Service | URL | Cara start |
|---|---|---|
| API (Laravel) | http://localhost:8000 | `php artisan serve --port=8000` |
| Web depan (nasabah) | http://localhost:3000 | `npm run dev` |
| CMS admin | http://localhost:3001 | `npm run dev -- --port 3001` |
| AI eKYC (opsional) | http://localhost:8001 | `uvicorn app.main:app --port 8001` |

**Akun demo (hasil seed):**
| Peran | Email | Password |
|---|---|---|
| Super Admin | `admin@sekuritas-demo.id` | `Admin@123456` |
| Ops | `ops@sekuritas-demo.id` | `Ops@123456` |
| Nasabah (10 org) | mis. `budi.santoso@mail.test` | `Nasabah@123` |

**Bahan:** siapkan 1 foto KTP (boleh contoh/dummy) & 1 foto wajah untuk di-upload/scan.
**OTP demo web:** `123456`.

> Tips rekaman: buka 2 browser / mode incognito terpisah — satu untuk **Nasabah** (`:3000`), satu untuk **Admin** (`:3001`) — agar bisa berpindah peran mulus.

---

## SKENARIO A — NASABAH (di `:3000`)

### A1. Jelajah publik (tanpa login) — 30 dtk
Narasi: "Ini portal Victoria Sekuritas."
1. Buka **http://localhost:3000** → tunjukkan **Home** (hero, produk unggulan, tabel NAV).
2. Klik **Reksa Dana** → filter kategori, buka **detail** satu produk (grafik NAV).
3. Klik **Bandingkan** → pilih 2–3 reksadana → tampil tabel perbandingan.
4. Klik **Promo** & **Artikel** sekilas.

### A2. Daftar akun — 30 dtk
1. Klik **Daftar** → masukkan **nomor HP** → centang S&K → **Selanjutnya**.
2. Masukkan **OTP `123456`** → buat **PIN** (6 digit) → konfirmasi PIN.
3. Otomatis masuk ke dashboard nasabah.

### A3. ⭐ eKYC (BINTANG UTAMA) — 1.5 menit
1. Dari dashboard/menu, buka **Verifikasi** → halaman **`/pembukaan-rekening/ekyc`**
   (atau di halaman KYC klik kartu **"Coba Verifikasi Otomatis (eKYC)"**).
2. **Langkah 1 — Foto e-KTP:** klik area upload → pilih foto KTP.
   - Narasi: "OCR gratis on-device membaca NIK & nama otomatis."
   - Tampil **"Data terbaca otomatis"** (NIK/Nama) → klik **Proses OCR**.
3. **Langkah 2 — Selfie (Liveness):** ambil/pilih foto wajah → klik **Cek Liveness & Wajah**.
   - Tampil **Liveness: LOLOS** + **Face Match: xx%**.
4. **Langkah 3 — Pencocokan Wajah:** tampil skor kecocokan → **Lanjut**.
5. **Langkah 4 — Tanda Tangan Digital:** gambar tanda tangan di kanvas → **Kirim & Verifikasi**.
6. **Langkah 5 — Hasil:** tampil **skor akhir** + keputusan (**Terverifikasi / Review / Ditolak**) beserta rincian OCR/Liveness/Face.
   - Narasi: "Sistem menghitung skor & memutuskan otomatis. Data ini masuk ke admin untuk verifikasi akhir."
7. Klik **Lanjut: Lengkapi Data**.

### A4. Lengkapi data pembukaan rekening — 45 dtk
1. **Data Pribadi** (NIK, nama ibu, TTL, alamat, dsb) → **Berikutnya**.
2. **Data Pekerjaan** (pekerjaan, penghasilan, sumber dana) → **Berikutnya**.
3. **Informasi Tambahan** (tujuan investasi) → centang pernyataan → **Kirim Data**.
   - Narasi: "Pengajuan dikirim, menunggu verifikasi admin."

### A5. (Opsional) Promo via link referral — 30 dtk
1. Buka link promo `http://localhost:3000/promo/<KODE>` (kode dari event di CMS).
2. Klik **Ikuti Event** → (kalau sudah login) tercatat; badge "datang dari promo" muncul saat daftar.

> **Pindah ke browser Admin untuk lanjut SKENARIO B.**

---

## SKENARIO B — OPS (di `:3001`)

Ops = verifikasi KYC & terbitkan SID (tidak bisa kelola produk/user — itu super admin).

### B1. Login — 15 dtk
1. Buka **http://localhost:3001** → login **`ops@sekuritas-demo.id` / `Ops@123456`**.

### B2. ⭐ Review KYC + hasil eKYC — 1 menit
1. Menu **KYC Management** → daftar pengajuan (status *pending*).
2. Buka salah satu nasabah (mis. yang barusan daftar, atau data seed).
3. Tunjukkan **panel "Verifikasi eKYC Otomatis"**: skor **OCR / Liveness / Face** + keputusan + flag fraud (jika ada) + provider.
4. Tunjukkan **foto KTP, selfie, tanda tangan**, dan data pribadi.
5. Klik **Approve KYC** → konfirmasi.
   - Narasi: "Approve KYC dulu — SID belum terbit."

### B3. ⭐ Terbitkan SID ke S-INVEST (2 langkah) — 30 dtk
1. Setelah approved, di kartu **SID & IFUA** muncul tombol **"Kirim ke S-INVEST"**.
2. Klik → tampil animasi → **SID** & **IFUA** terbit (mode simulasi KSEI).
   - Narasi: "Penerbitan SID dipisah dari approve, jadi ops punya kontrol dua langkah. Di produksi, tombol ini mengirim data ke KSEI asli."

### B4. Kelola Promo/Event (kalau ops diberi akses) — 45 dtk
1. Menu **Event & Promo** → **Tambah Event** (isi nama, tipe, MI, periode, kuota reward).
2. Klik **Salin link** → itulah link referral untuk kampanye (lihat A5).
3. Klik **Leaderboard** pada sebuah event → daftar peserta + reward eligible → **Export CSV**.

---

## SKENARIO C — SUPER ADMIN (di `:3001`)

Super admin = semua akses.

### C1. Login — 15 dtk
1. Logout ops → login **`admin@sekuritas-demo.id` / `Admin@123456`**.

### C2. Dashboard & kelola data — 1.5 menit
1. **Dashboard** → ringkasan nasabah/transaksi/AUM/event.
2. **Users** → daftar nasabah, ubah status akun.
3. **Products** → tunjukkan CRUD produk + **update NAV** (individual / massal).
4. **Artikel** → buat/edit artikel edukasi (tampil di web depan).
5. **Event & Promo** → sama seperti B4 (buat event, leaderboard, export, upload banner).
6. **Reports** → laporan/transaksi.
7. (Ulangi B2–B3 bila mau: super admin juga bisa approve KYC & terbitkan SID.)

---

## SKENARIO D — NASABAH BELI PRODUK (di `:3000`, setelah SID aktif)

> Prasyarat: KYC nasabah sudah **approved** & **SID terbit** (Skenario B). Kembali ke browser Nasabah.

### D1. Pilih & beli reksadana — 1 menit
1. Menu **Reksa Dana** → buka **detail** salah satu produk (lihat NAV, min. pembelian, grafik).
2. Klik **Beli** → masuk halaman pembelian (`/transaksi/subscribe`).
3. Isi **nominal** (mis. Rp 1.000.000) → pilih **metode pembayaran** (Virtual Account) → **Konfirmasi**.
   - Narasi: "Estimasi unit dihitung otomatis dari NAV."

### D2. Pembayaran (mode simulasi) — 30 dtk
1. Tampil **Nomor Virtual Account** + batas waktu bayar.
   - Narasi: "Di produksi ini VA/QRIS asli dari Midtrans; sekarang mode simulasi."
2. (Simulasi lunas) — status transaksi berpindah ke **Diproses/Selesai**.

### D3. Transaksi & Portofolio — 30 dtk
1. Menu **Transaksi** → tab **Dalam Proses** / **Selesai** → buka detail (timeline status).
2. Menu **Portofolio** → tunjukkan nilai investasi, unit, dan imbal hasil.
   - Narasi: "Nasabah kini punya portofolio aktif."

> (Opsional untuk video) Perlihatkan lagi di **CMS → Transactions** bahwa transaksi nasabah tercatat di sisi admin.

---

## (Opsional) Demo eKYC di MOBILE
1. Jalankan: `cd sekuritas-mobile && flutter run --dart-define=API_BASE=http://10.0.2.2:8000/api` (emulator Android).
2. Login/daftar → menu KYC → **"Mulai Verifikasi eKYC"**.
3. **Foto KTP (kamera)** → **Proses OCR** → **Selfie** → **Cek Liveness & Wajah** → **Tanda tangan** → **Kirim & Verifikasi** → tampil skor & keputusan.

---

## Ringkasan alur untuk narasi video
```
NASABAH: daftar → eKYC (KTP→OCR→selfie→liveness→face→ttd→verifikasi) → lengkapi data → kirim
   ↓ (data masuk sistem)
OPS: review KYC + lihat skor eKYC → Approve → "Kirim ke S-INVEST" → SID & IFUA terbit
   ↓ (nasabah jadi AKTIF)
NASABAH: beli reksadana → bayar (VA simulasi) → transaksi Diproses/Selesai → Portofolio
   ↓
SUPER ADMIN: kelola produk/NAV/artikel/event/laporan + pantau transaksi (kontrol penuh)
```

**Urutan rekaman yang disarankan:** A (nasabah: daftar→eKYC→data) → B (ops: approve→kirim S-INVEST) → D (nasabah: beli produk) → C (super admin: kelola & pantau).

## Catatan yang perlu diucapkan di video
- eKYC berjalan **mode stub** (nol biaya) untuk demo; di produksi tinggal ganti ke model asli (PaddleOCR/InsightFace) atau vendor tersertifikasi — arsitektur adapter sudah siap.
- Penerbitan **SID** & **pembayaran** juga mode simulasi; siap disambung ke **KSEI** & **Midtrans** saat kredensial klien tersedia.
- Email (aktivasi/lengkapi akun) tersimpan di `sekuritas-api/storage/logs/laravel.log` (karena `MAIL_MAILER=log`).
