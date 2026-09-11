# Tutorial & Skrip Demo — Victoria Sekuritas (fokus eKYC)

Panduan langkah-demi-langkah untuk **merekam video demo**. Tiga peran: **Nasabah**, **Ops**, **Super Admin**. Alur inti: nasabah daftar → **eKYC** → data → transaksi; ops **review KYC + terbitkan SID**; super admin kelola semua.

> Mode demo: `PAYMENT_GATEWAY=mock`, `SINVEST_DRIVER=mock`. Semua jalan tanpa kredensial pihak ketiga.
>
> **Penting soal eKYC:** OCR KTP sekarang **hanya** dibaca oleh server AI (`sekuritas-ai`, Nanonets-OCR).
> - `EKYC_PROVIDER=fastapi` + model asli → foto KTP **mengisi form otomatis** (disarankan untuk demo ke klien — lihat `DEPLOY_VPS.md` mode A).
> - `EKYC_PROVIDER=stub` → alur & skor tetap jalan, tetapi **NIK/nama tidak terisi otomatis** (ketik manual di langkah Data Pribadi).

---

## 0. Persiapan sebelum rekaman

### 0a. Demo dari SERVER (disarankan untuk klien)
Ikuti **`DEPLOY_VPS.md`** → buka `https://app.DOMAIN` (nasabah) & `https://cms.DOMAIN` (admin).
HTTPS diperlukan agar tombol **Buka Kamera** bisa dipakai di HP.

### 0b. Demo LOKAL (laptop) — lakukan sekali
> Butuh: PHP 8.2+, Composer, Node 20, (opsional Python **3.11** untuk AI). Tidak perlu PostgreSQL — otomatis pakai SQLite.
> Semua repo di-clone **sejajar** di `freelance/sekuritas/` (sekuritas-api, -frontend, -cms, -ai, -mobile, -infra).

```bash
cd /Users/user/Documents/freelance/sekuritas
bash sekuritas-infra/install-all.sh     # install semua + .env + SQLite + migrate:fresh --seed
```
Lalu 3 terminal:
```bash
cd sekuritas-api && php artisan serve --port=8000          # cek http://localhost:8000/api/health
cd sekuritas-frontend && npm run dev                        # http://localhost:3000
cd sekuritas-cms && npm run dev -- --port 3001              # http://localhost:3001
```
AI lokal (opsional, mode stub — model asli butuh RAM besar, lebih cocok di server):
```bash
cd sekuritas-ai && .venv/bin/uvicorn app.main:app --port 8001
# sekuritas-api/.env: EKYC_PROVIDER=fastapi, EKYC_FASTAPI_URL=http://localhost:8001, EKYC_FASTAPI_KEY=<EKYC_AI_API_KEY di sekuritas-ai/.env>
```
Reset data demo kapan saja: `cd sekuritas-api && php artisan migrate:fresh --seed`.

### 0c. Service & URL
| Service | Lokal | Server |
|---|---|---|
| API (Laravel) | http://localhost:8000 | https://api.DOMAIN |
| Web depan (nasabah) | http://localhost:3000 | https://app.DOMAIN |
| CMS admin | http://localhost:3001 | https://cms.DOMAIN |
| AI eKYC | http://localhost:8001 (opsional) | internal (tidak publik) |

**Akun demo (hasil seed — otomatis dibuat saat `migrate:fresh --seed` / container api pertama jalan):**

| Peran | Login di | Versi Danapathi (branch `danapathi`) | Versi Victoria (`main`) | Password |
|---|---|---|---|---|
| **Super Admin** (semua menu) | CMS | `superadmin@danapathi-demo.id` | `admin@sekuritas-demo.id` | `Admin@123456` |
| **Ops** (KYC + SID) | CMS | `ops@danapathi-demo.id` | `ops@sekuritas-demo.id` | `Ops@123456` |
| **Member aktif** (KYC ✔, SID ✔, punya portofolio — demo beli/portofolio) | Web | `member@danapathi-demo.id` | `member@sekuritas-demo.id` | `Member@123` |
| **Member baru** (sudah aktivasi, BELUM KYC — demo eKYC dari awal) | Web | `member.baru@danapathi-demo.id` | `member.baru@sekuritas-demo.id` | `Member@123` |
| 10 nasabah acak (status KYC campur) | Web | mis. `budi.santoso@mail.test` | sama | `Nasabah@123` |

> **Di server demo** password-nya BUKAN default di atas (repo publik) — diambil dari `DEMO_*_PASSWORD` di `.env` server;
> catatan lengkapnya ada di file lokal `AKUN_DEMO.md` (tidak di-commit).
>
> Setelah "Member baru" dipakai demo eKYC, datanya sudah terisi. Untuk mengulang demo: reset data
> (`php artisan migrate:fresh --seed`, di server: `docker compose exec api php artisan migrate:fresh --seed --force`)
> atau daftar akun baru lewat halaman Daftar.

**Bahan:** 1 foto KTP (contoh: `sekuritas-infra/design/ktp.jpeg`) & 1 foto selfie sambil memegang KTP.
**Email aktivasi:** kalau `MAIL_MAILER=log`, ambil link aktivasi dari log:
- lokal: `grep -o 'aktivasi?token=[A-Za-z0-9]*' sekuritas-api/storage/logs/laravel.log | tail -1`
- server: `docker compose exec api grep -o 'aktivasi?token=[A-Za-z0-9]*' storage/logs/laravel.log | tail -1`

lalu buka `<URL web>/aktivasi?token=...`. Atau lewati pendaftaran dengan login nasabah seed.

> Tips rekaman: buka 2 browser / mode incognito terpisah — satu untuk **Nasabah** (`:3000`), satu untuk **Admin** (`:3001`) — agar bisa berpindah peran mulus.

---

## SKENARIO A — NASABAH (di `:3000`)

### A1. Jelajah publik (tanpa login) — 30 dtk
Narasi: "Ini portal Victoria Sekuritas."
1. Buka **http://localhost:3000** → tunjukkan **Home** (hero, produk unggulan, tabel NAV).
2. Klik **Reksa Dana** → filter kategori, buka **detail** satu produk (grafik NAV).
3. Klik **Bandingkan** → pilih 2–3 reksadana → tampil tabel perbandingan.
4. Klik **Promo** & **Artikel** sekilas.

### A2. Daftar akun (alur ala CGS: email → aktivasi) — 45 dtk
1. Klik **Daftar** (`/register`) → isi **Email**, **Password** (min. 8), **Konfirmasi Password** → centang S&K → **Daftar**.
2. Tampil **"Cek Email Anda"** → buka email **aktivasi** (atau ambil link dari log, lihat bagian 0) → klik link → halaman **Akun berhasil diaktivasi**.
3. Klik **Masuk Sekarang** → login email + password → otomatis diarahkan ke **Pembukaan Rekening Online** (`/pembukaan-rekening/ekyc`).

### A3. ⭐ Pembukaan Rekening + eKYC (BINTANG UTAMA) — 2.5 menit
Satu alur **5 langkah** (stepper di atas: Verifikasi → Data Pribadi → Data Pekerjaan → Informasi Tambahan → Persyaratan).
1. **Verifikasi — Foto e-KTP:** pilih **Upload File** atau **Buka Kamera** (bingkai KTP) → muncul "Membaca KTP…".
   - Tampil **"Data terbaca otomatis"** (NIK, Nama, TTL, Kelamin, Alamat) + badge **Verifikasi NIK: Valid**.
   - Narasi: "AI membaca KTP dan mengisi form otomatis; NIK divalidasi (demo: parser NIK, produksi: Dukcapil)."
   - *(Mode stub: kotak ini tidak muncul — lanjut dan isi data manual.)*
2. **Data Pribadi:** sudah terisi dari KTP → lengkapi nama ibu kandung, status nikah, pendidikan → **Berikutnya**.
3. **Data Pekerjaan:** pekerjaan, nama perusahaan, penghasilan, sumber dana → **Berikutnya**.
4. **Informasi Tambahan:** tujuan investasi, pengalaman, tahu dari mana → **Berikutnya**.
5. **Persyaratan & Ketentuan:**
   - Baca S&K → centang persetujuan.
   - **Selfie dengan e-KTP** (Upload / Kamera: wajah di oval, KTP di kotak bawah) → dipakai untuk **liveness + face match**.
   - (Opsional) foto **NPWP** & **Buku Tabungan**.
   - Gambar **Tanda Tangan** & **Paraf** di kanvas → **Submit**.
6. Tampil **"Pengajuan Terkirim!"** + **Skor eKYC** & status *Pending (menunggu review)*.
   - Narasi: "Sistem menghitung skor OCR + liveness + kecocokan wajah. Data masuk ke admin untuk verifikasi akhir."

### A4. (Opsional) Promo via link referral — 30 dtk
1. Buka link promo `http://localhost:3000/promo/<KODE>` (kode dari event di CMS).
2. Klik **Ikuti Event** → (kalau sudah login) tercatat; badge "datang dari promo" muncul saat daftar.

> **Pindah ke browser Admin untuk lanjut SKENARIO B.**

---

## SKENARIO B — OPS (di `:3001`)

Ops = verifikasi KYC & terbitkan SID (tidak bisa kelola produk/user — itu super admin).

### B1. Login — 15 dtk
1. Buka **http://localhost:3001** → login **Ops** (lihat tabel akun: `ops@danapathi-demo.id` / `Ops@123456`).

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
2. Klik **Salin link** → itulah link referral untuk kampanye (lihat A4).
3. Klik **Leaderboard** pada sebuah event → daftar peserta + reward eligible → **Export CSV**.

---

## SKENARIO C — SUPER ADMIN (di `:3001`)

Super admin = semua akses.

### C1. Login — 15 dtk
1. Logout ops → login **Super Admin** (`superadmin@danapathi-demo.id` / `Admin@123456`).

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
NASABAH: daftar email → aktivasi → login → pembukaan rekening 5 langkah
         (KTP→OCR auto-isi → data pribadi → pekerjaan → info tambahan → selfie+KTP, ttd & paraf) → submit
   ↓ (data masuk sistem)
OPS: review KYC + lihat skor eKYC → Approve → "Kirim ke S-INVEST" → SID & IFUA terbit
   ↓ (nasabah jadi AKTIF)
NASABAH: beli reksadana → bayar (VA simulasi) → transaksi Diproses/Selesai → Portofolio
   ↓
SUPER ADMIN: kelola produk/NAV/artikel/event/laporan + pantau transaksi (kontrol penuh)
```

**Urutan rekaman yang disarankan:** A (nasabah: daftar→eKYC→data) → B (ops: approve→kirim S-INVEST) → D (nasabah: beli produk) → C (super admin: kelola & pantau).

## Catatan yang perlu diucapkan di video
- eKYC memakai model AI open-source yang di-host sendiri (Nanonets-OCR untuk KTP, InsightFace untuk kecocokan wajah, Facenox untuk liveness) — tanpa biaya per transaksi. Bisa diganti vendor tersertifikasi (Privy/ADVANCE.AI dsb.) karena arsitektur adapter sudah siap.
- Penerbitan **SID** & **pembayaran** juga mode simulasi; siap disambung ke **KSEI** & **Midtrans** saat kredensial klien tersedia.
- Bila `MAIL_MAILER=log`, email (aktivasi/lengkapi akun) tersimpan di `storage/logs/laravel.log` API; di server demo sebaiknya pakai SMTP agar email benar-benar terkirim.
