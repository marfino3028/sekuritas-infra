buatin proposal terkait ini /Users/user/Documents/freelance/sekuritas dengan prompt itu dengan project nya ada didalam nya ya
# PROPOSAL PENAWARAN
## Pengembangan Platform Investasi Reksadana — Victoria Sekuritas

**Kepada Yth.** Tim Victoria Sekuritas
**Perihal:** Penawaran Pengembangan Website, Content Management System (CMS), Backend API, dan Aplikasi Mobile
**Tanggal:** _____________
**Berlaku sampai:** 30 hari sejak tanggal penawaran

---

## 1. Latar Belakang & Tujuan

Victoria Sekuritas membutuhkan platform digital investasi reksadana yang **mengadopsi alur (flow) pembukaan rekening & transaksi setara CGS iTradeFund**, namun dengan **identitas visual Victoria yang modern, eye-catching, dan menarik calon investor untuk melakukan registrasi**.

Platform terdiri dari:
- **Website Depan (publik)** — marketing + Online Account Opening (pembukaan rekening online) + katalog & transaksi reksadana.
- **CMS Admin** — pengelolaan produk, artikel/edukasi, promo/event, verifikasi KYC nasabah, transaksi, laporan.
- **Backend API** — mesin data untuk website, CMS, dan aplikasi mobile.
- **Aplikasi Mobile (opsional / add-on)** — Android (& iOS) untuk nasabah bertransaksi dari HP.

Dilengkapi: **modul Promo/Event berbasis link referral** (untuk kampanye khusus dengan reward/keuntungan tertentu), **eKYC** (verifikasi identitas), **tanda tangan digital (Privy)**, dan **integrasi S-Invest/SID (KSEI)**.

---

## 2. Ruang Lingkup Pekerjaan

### 2.1 Website Depan (Publik)
- Homepage modern (hero, produk unggulan, tabel kinerja NAV, keunggulan, edukasi, mitra Manajer Investasi, CTA registrasi).
- Halaman **Produk Reksadana**: list + filter kategori (Pasar Uang, Pendapatan Tetap, Saham, Indeks, Campuran, Syariah, Terproteksi, Endowment), pencarian, sorting.
- **Detail Produk**: grafik NAV & AUM, min. pembelian, bank kustodian, dokumen (prospektus, fund fact sheet), tombol Beli.
- **Bandingkan Reksadana** & **Bandingkan Manajer Investasi** (pilih beberapa, tampil grafik & tabel perbandingan).
- **Promo/Event**: halaman daftar promo + landing per-event via link khusus (`/promo/{kode}`) dengan tracking pendaftaran & benefit.
- **Education/Artikel**: list + detail artikel.
- **Login, Register, Lupa Password**.
- **Alur Pembukaan Rekening Online (5 langkah)**: Verifikasi (eKYC e-KTP) → Data Pribadi → Data Pekerjaan → Informasi Tambahan → Persyaratan & Ketentuan (tanda tangan digital), termasuk RDN & SID.
- Responsive (desktop, tablet, mobile), SEO dasar, animasi/micro-interaction.

### 2.2 CMS Admin
- Dashboard ringkasan (nasabah, transaksi, AUM, event).
- Manajemen: Produk & NAV (termasuk update NAV massal), Artikel, **Promo/Event** (buat event, kode, benefit, leaderboard, export peserta), Transaksi, Nasabah/User.
- **Verifikasi KYC**: review dokumen, approve/reject.
- Laporan & export.
- Manajemen role admin.

### 2.3 Backend API
- Autentikasi (OTP + register), produk, NAV history, transaksi (subscribe/redeem), pembayaran + webhook, portofolio, profil risiko, event/promo + registrasi, artikel.
- Integrasi: **eKYC**, **Privy (tanda tangan digital)**, **S-Invest/SID**, **payment gateway**, **email** (link aktivasi & dokumen pembukaan rekening).
- Keamanan: JWT, rate limit, enkripsi data sensitif, audit dasar.

### 2.4 Aplikasi Mobile (ADD-ON — lihat paket)
- Flutter (Android; iOS opsional).
- Onboarding, register/OTP/PIN, KYC (scan KTP + tanda tangan), home, katalog & detail produk, beli/jual, pembayaran, portofolio, transaksi, notifikasi, profil.
- Build APK siap distribusi (Play Store opsional).

### 2.5 Integrasi Pihak Ketiga
- **eKYC**: tahap awal memakai solusi **gratis/free-tier** (mis. OCR KTP on-device + liveness sederhana). Upgrade ke penyedia tersertifikasi (Privy/Verihubs) saat produksi.
- **Privy**: tanda tangan digital tersertifikasi (mode sandbox untuk demo).
- **S-Invest/SID (KSEI)**: adapter siap-sambung; demo memakai simulasi generate SID.
- **Payment Gateway**: Midtrans/Xendit + opsi upload bukti manual.

---

## 3. Paket & Harga

Semua harga dalam Rupiah, **belum termasuk biaya pihak ketiga** (lihat §4) dan **belum termasuk PPN** (jika ada).

| Paket | Cakupan | Harga |
|-------|---------|-------|
| **Paket A — Web + CMS + API** | Website depan (lengkap, termasuk online account opening, eKYC free-tier, Privy sandbox, promo/event, integrasi email & payment) + CMS Admin + Backend API. **Tanpa aplikasi mobile.** | **Rp 145.000.000** |
| **Paket B — A + Mobile Android** ⭐ *Rekomendasi* | Semua isi Paket A **+ Aplikasi Mobile Flutter (Android/APK)** tersambung ke API yang sama. | **Rp 200.000.000** |
| **Paket C — B + iOS + Support** | Semua isi Paket B **+ build iOS** + **3 bulan maintenance & support** setelah go-live. | **Rp 240.000.000** |

> **Rekomendasi: Paket B (Rp 200.000.000).** Alasan: website depan + CMS + API adalah kebutuhan utama saat ini, dan aplikasi Android melengkapi flow pembayaran/transaksi nasabah (seperti pada video `home-klikbeli...masukkeappvictoriasekuritas...gif`) dengan tambahan biaya yang wajar (+Rp 55.000.000 dari Paket A). iOS bisa ditambahkan belakangan.

### Add-on terpisah (bila tidak ambil paket bundling)
| Add-on | Harga |
|--------|-------|
| Aplikasi Mobile Android (jika ambil Paket A dulu) | Rp 55.000.000 |
| Build iOS (App Store) | Rp 30.000.000 |
| Integrasi eKYC/Privy/S-Invest tersertifikasi (produksi, per integrasi) | mulai Rp 15.000.000 (jasa integrasi; lisensi ditanggung klien) |
| Maintenance & support bulanan | Rp 7.500.000 / bulan |

---

## 4. Biaya Pihak Ketiga (ditanggung klien, di luar jasa)

Biaya berlangganan/lisensi berikut **bukan** bagian dari harga di atas:
- Lisensi **Privy** (tanda tangan digital tersertifikasi).
- **eKYC** produksi (Verihubs/Privy/dsb) — per verifikasi.
- Keanggotaan/akses **S-Invest (KSEI)**.
- **Payment gateway** (Midtrans/Xendit) — fee per transaksi.
- **Hosting/VPS**, domain, email service, penyimpanan file (S3/dsb).

Selama pengembangan/demo, komponen ini memakai **mode gratis/sandbox** agar tidak menimbulkan biaya.

---

## 5. Timeline (estimasi)

| Fase | Durasi | Output |
|------|--------|--------|
| 1. Finalisasi design system & UI kit Victoria | 1 minggu | Design tokens, komponen, halaman kunci |
| 2. Backend API (penyempurnaan + integrasi) | 3 minggu | API siap, integrasi eKYC/Privy/S-Invest/payment |
| 3. Website depan + Online Account Opening | 4 minggu | Web publik lengkap |
| 4. CMS Admin (rebrand + fitur promo/event) | 2 minggu | CMS siap |
| 5. Aplikasi Mobile (jika Paket B/C) | 3 minggu | APK/iOS |
| 6. Testing, UAT, revisi, go-live | 2 minggu | Deploy produksi |

**Total estimasi: ± 12–14 minggu** (fase dapat paralel). Tanpa mobile ± 9–11 minggu.

---

## 6. Termin Pembayaran (usulan)

- **30%** — DP saat kontrak ditandatangani.
- **30%** — setelah backend API + CMS selesai (milestone tengah).
- **30%** — setelah website depan + mobile (jika ada) selesai & UAT.
- **10%** — setelah go-live & serah terima.

---

## 7. Yang Termasuk & Tidak Termasuk

**Termasuk:** source code seluruh repo (web, CMS, API, mobile), dokumentasi teknis dasar, deployment awal, revisi wajar selama pengembangan, garansi bug **30 hari** setelah go-live (Paket A/B) / **3 bulan** (Paket C).

**Tidak termasuk:** biaya pihak ketiga (§4), pembuatan konten (artikel/foto/copywriting final), lisensi resmi OJK/KSEI, penambahan fitur di luar ruang lingkup (dikenakan biaya terpisah), maintenance jangka panjang (kecuali Paket C / add-on).

---

## 8. Catatan Kepatuhan

Integrasi resmi eKYC tersertifikasi, Privy, S-Invest (KSEI), dan operasional sebagai Perusahaan Efek tunduk pada **regulasi OJK & KSEI**. Pada tahap ini platform dibangun **fungsional & siap-integrasi**; aktivasi ke sistem resmi dilakukan setelah izin/keanggotaan klien tersedia.

---

*Hormat kami,*
**Marfino Hamzah** — Jasa Pengembangan Software
Kontak: _____________
