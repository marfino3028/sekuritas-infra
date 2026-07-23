# Victoria Sekuritas — Analisa Repo & Design System

Dokumen ini merangkum (1) hasil analisa 3 repo yang sudah ada, (2) gap terhadap flow CGS iTradeFund, dan (3) design system Victoria yang harus dipakai di semua platform (web depan, CMS, mobile).

Referensi flow asli ada di folder `design/` (file `.mov` asli di `design/asli/`, versi `.gif` untuk preview, `.png` screenshot, `.eml` email). Peta lengkap asset → fitur ada di `PROMPTS.md`.

---

## 1. Status repo saat ini

| Repo | Stack | Status | Catatan |
|------|-------|--------|---------|
| `sekuritas-api` | Laravel (Railway) | **Cukup lengkap** | auth OTP+register, products, events (kode + leaderboard), articles, KYC, risk-profile, transactions, payment, portfolio, + CMS API. Migrasi `sid_data`, `events`, `event_registrations` sudah ada. |
| `sekuritas-cms` | Nuxt 3 + Tailwind (Pinia) | **Cukup lengkap** | dashboard, kyc, products, articles, events, transactions, users, reports. Warna masih teal `#009688`. |
| `sekuritas-mobile` | Flutter (Riverpod + go_router + dio) | **Struktur nyata** | auth (invitation code/OTP/PIN), KYC (KTP/personal/bank/risk/signature), home, explore, portfolio, transaction, profile. README masih "sekuritas_demo". |
| **web depan publik** | — | **BELUM ADA** | Situs marketing + Online Account Opening seperti `app.itradefund.cgsi.co.id` + `register.cgsi.co.id`. Ini prioritas utama. |

## 2. Gap terhadap flow CGS iTradeFund (yang harus dikerjakan)

1. **Web depan belum ada** — home, promo, produk (list + detail + bandingkan), education/artikel, login, register. Semua ada di screenshot & gif design.
2. **eKYC** — belum ada integrasi. Rencana: pakai provider gratis/free-tier (lihat §5). Screenshot `izinkanakseskamera.png` + `isiverifikasi...gif` = langkah scan e-KTP + liveness.
3. **Privy (tanda tangan digital)** — belum ada. Dipakai di langkah "Persyaratan & Ketentuan" (`lanjutanpersyaratan&ketentuan.gif`).
4. **S-Invest / SID (KSEI)** — tabel `sid_data` ada, tapi belum ada flow generate SID / registrasi ke S-Invest.
5. **Warna & brand** — semua platform masih memakai warna CGS (merah+navy) atau teal default. Harus diganti ke palet Victoria (§3).
6. **Promo/Event dengan link referral** — API `events` + `event_registrations` sudah ada (kode event + leaderboard). Perlu: halaman promo publik, landing per-event (`/promo/{code}`), tracking pendaftaran via link, dan benefit/reward di CMS.
7. **Email** — 2 template (`Registration CGS International.eml` = link aktivasi, `Complete Account.eml` = kirim dokumen untuk ditandatangani). Harus dibuat versi Victoria.

## 3. Design System Victoria (WAJIB dipakai di semua platform)

Brand Victoria = korporat, terpercaya, tapi diminta **lebih kekinian / modern / eye-catching** dari CGS. Arah: navy tepercaya + emas premium + aksen fresh, banyak white-space, kartu rounded, gradient halus, ilustrasi 3D finance.

> **CATATAN PALET (FINAL — dari logo asli Victoria):** Warna brand resmi Victoria =
> **MERAH `#A40001`** (ornamen pada logo) + wordmark hitam di atas **netral hangat**.
> Palet resmi dari `design/asset+logo/`: `#a40001 #f0f3ec #c67177 #d59997 #fffdfc #e2dad3 #d2d7d3`.
> Dipakai konsisten di web depan, CMS, mobile, dan email.
> - primary **`#A40001`**, hover `#7D0001`; accent rose `#C67177` / light `#D59997`
> - bg krem `#F0F3EC`, surface `#FFFDFC`, border hangat `#E2DAD3`, grey `#D2D7D3`, teks `#1A1A1A`
> - gradient hero: `linear-gradient(135deg,#7D0001,#A40001 45%,#C67177)`
>
> Palet navy/emas & "Indigo Premium" di bawah/riwayat = proposal lama, **tidak dipakai lagi**.

### Palet warna (proposal awal — lihat catatan di atas)
```
--vs-navy-900   #0A1F44   (background hero gelap, teks utama)
--vs-navy-700   #0B2A5B   (primary brand)
--vs-blue-600   #1E56C9   (primary action / tombol)
--vs-blue-500   #2F6BFF   (link, focus)
--vs-gold-500   #F5B301   (aksen emas Victoria — CTA sekunder, highlight)
--vs-gold-400   #FFCB3D   (hover emas)
--vs-teal-400   #17B0A6   (aksen fresh untuk grafik naik / sukses)
--vs-red-500    #E23B3B   (nilai turun / error)
--vs-slate-50   #F5F7FB   (background section)
--vs-slate-200  #E4E9F2   (border)
--vs-white      #FFFFFF
```
Gradient hero: `linear-gradient(135deg,#0A1F44 0%,#0B2A5B 55%,#1E56C9 100%)` + aksen emas.

### Tipografi
- Heading: **Plus Jakarta Sans** (atau Sora) — bold, modern, khas Indonesia.
- Body: **Inter**.
- Angka finansial (NAV, %): tabular-nums.

### Komponen
- Radius: kartu `16px`, tombol `12px`, input `10px`.
- Shadow lembut: `0 8px 30px rgba(11,42,91,.08)`.
- Tombol primary: biru `#1E56C9`, teks putih; secondary: emas `#F5B301`, teks navy.
- Badge status: hijau/teal = naik, merah = turun (persis pola panah ▲▼ di iTradeFund).
- Progress stepper registrasi 5 langkah (Verifikasi → Data Pribadi → Data Pekerjaan → Informasi Tambahan → Persyaratan & Ketentuan) — sama seperti `register.png`, tapi warna Victoria + lebih modern (garis progress emas).

### Nada visual "kekinian"
- Ilustrasi 3D koin/rumah/panah (seperti iTradeFund) tapi tone biru-emas.
- Micro-interaction: hover lift kartu, animasi angka NAV count-up, skeleton shimmer saat loading.
- Section "Kenapa Victoria" dengan ikon, "Manajer Investasi Pilihan" grid logo, testimoni, CTA "Investasi Sekarang".

## 4. Flow registrasi (persis CGS, warna Victoria)

1. **Register User ID** — buat User ID + email + password + setuju S&K → kirim email **Link Aktivasi** (template `Registration ... .eml`).
2. **Aktivasi & login** — klik link email → login pakai email+password.
3. **Verifikasi (step 1/5)** — kewarganegaraan, **scan e-KTP (eKYC + izin kamera)**, kategori akun, no KTP, nama, nama ibu kandung, jenis kelamin, tempat/tgl lahir, rekening tabungan, **Rekening Dana Nasabah (RDN)**.
4. **Data Pribadi (2/5)**, **Data Pekerjaan (3/5)**, **Informasi Tambahan (4/5)**.
5. **Persyaratan & Ketentuan (5/5)** — **tanda tangan digital via Privy**, generate SID via **S-Invest**.
6. **Complete Account** — email dokumen pembukaan rekening (template `Complete Account.eml`).
7. **Beli reksadana** — pilih produk → detail → beli → bayar (upload bukti / payment gateway) → transaksi proses → selesai.

## 5. Integrasi pihak ketiga

- **eKYC gratis/free-tier** (harus dicek kuota & syarat produksi):
  - **Verihubs** / **Privy** (Privy juga punya eKYC + liveness) — ada trial.
  - **Google ML Kit Text Recognition** (on-device, gratis) untuk OCR KTP di mobile + face detection untuk liveness sederhana — 0 biaya lisensi, cocok untuk MVP/demo.
  - Rekomendasi demo: OCR KTP pakai **ML Kit / Tesseract** (gratis) + liveness sederhana (deteksi wajah + gerakan). Untuk produksi resmi: upgrade ke Privy/Verihubs berbayar.
- **Privy** — tanda tangan digital tersertifikasi (registration `register.privy.id`). API enterprise berbayar; sediakan mode sandbox.
- **S-Invest (KSEI)** — pembuatan Single Investor ID; integrasi resmi butuh keanggotaan. Untuk demo: simulasikan generate SID di `sid_data`, siapkan adapter agar mudah disambung ke API resmi.
- **Payment gateway** — Midtrans/Xendit untuk pembelian reksadana + upload bukti manual.

> Biaya lisensi Privy, eKYC produksi, S-Invest, payment gateway, dan hosting = **biaya pihak ketiga**, ditanggung klien di luar jasa pengembangan (lihat proposal).
