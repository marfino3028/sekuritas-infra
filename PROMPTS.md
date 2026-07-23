# PROMPTS LANJUTAN — Victoria Sekuritas

Rangkaian prompt siap-pakai untuk melanjutkan pengerjaan **satu per satu** (mis. di Claude free bila context habis). Setiap prompt **berdiri sendiri** dan menyebut **file asset spesifik** di folder `design/` sebagai contoh visual.

> **STATUS (per 2026-07-22):** P0–P17 **✅ SELESAI** (kode dibuat & di-push). P18 **⚠️ SEBAGIAN** (QA end-to-end belum dijalankan penuh).
> Catatan: bagian "integrasi asli" (Privy tersertifikasi, S-INVEST/KSEI, payment gateway, model AI produksi) **sudah disiapkan lewat adapter** tapi **butuh kredensial klien** untuk diaktifkan — lihat `PROGRESS.md`.
> Legenda: ✅ SELESAI · ⚠️ SEBAGIAN · ⛔ BELUM. (Web depan dibuat sebagai repo `sekuritas-frontend`, bukan `sekuritas-web` seperti disebut di prompt lama.)

## Cara pakai
1. Buka terminal/Claude di dalam folder repo yang relevan (`sekuritas-web`, `sekuritas-cms`, `sekuritas-api`, atau `sekuritas-mobile`).
2. Copy **HEADER KONTEKS** di bawah + **satu prompt** (P0, P1, dst) ke Claude.
3. Buka file asset yang disebut (mis. `design/home.png` atau `design/xxx.gif`) sebagai referensi visual — kalau tool bisa baca gambar, sebutkan path-nya; kalau tidak, buka manual & jelaskan.
4. Kerjakan urut: **P0 → P1 → ...** (P0 wajib duluan).

Peta asset: file `.mov` asli di `design/asli/`, `.gif` = preview flow, `.png` = screenshot statis, `.eml` = template email. Warna & flow lengkap ada di `ANALISA_DAN_DESIGN.md`.

---

## HEADER KONTEKS (tempel di setiap prompt)

```
Proyek: Platform investasi reksadana "Victoria Sekuritas" — MENIRU FLOW CGS iTradeFund
(app.itradefund.cgsi.co.id) PERSIS, tapi DESIGN & WARNA memakai brand Victoria yang
modern/kekinian/eye-catching.

Repo yang sudah ada:
- sekuritas-api    : Laravel (backend, sudah cukup lengkap)
- sekuritas-cms    : Nuxt 3 + Tailwind (admin)
- sekuritas-mobile : Flutter (Riverpod, go_router, dio)
- sekuritas-web    : (BARU) website depan publik — dibuat di P1

BRAND VICTORIA (pakai di semua UI):
- Navy #0A1F44 / #0B2A5B (primary), Biru aksi #1E56C9, Link #2F6BFF
- Emas #F5B301 (aksen/CTA sekunder), Teal #17B0A6 (nilai naik), Merah #E23B3B (turun)
- BG #F5F7FB, border #E4E9F2
- Font heading: Plus Jakarta Sans; body: Inter; angka finansial tabular-nums
- Radius kartu 16px / tombol 12px, shadow lembut 0 8px 30px rgba(11,42,91,.08)
- Gradient hero: linear-gradient(135deg,#0A1F44,#0B2A5B 55%,#1E56C9)
- Nuansa: white-space lega, kartu rounded, ilustrasi 3D finance biru-emas,
  micro-interaction (hover lift, NAV count-up, skeleton shimmer)

Aturan: flow = TIRU CGS, tampilan = Victoria. Semua teks Bahasa Indonesia.
Setelah selesai, jalankan build/lint dan (jika diminta) commit & push ke main.
```

---

# BAGIAN A — WEBSITE DEPAN (repo baru `sekuritas-web`)

## P0 — Setup design system & scaffold web  ✅ SELESAI
**Asset:** `design/home.png`, `design/login.png`
```
[TEMPEL HEADER KONTEKS]

Tugas P0: Buat repo baru "sekuritas-web" (Nuxt 3 + Tailwind + Pinia, struktur mirip
sekuritas-cms). Susun DESIGN SYSTEM Victoria sebagai fondasi:
- tailwind.config.ts dengan palet & font brand Victoria di atas.
- Komponen dasar: Button (primary/secondary/ghost), Card, Badge (naik/turun/status),
  Input, Select, Navbar publik, Footer, Container.
- Layout publik dengan Navbar (menu: Home, Promo, Produk, Education, tombol Masuk/Daftar)
  dan Footer (izin OJK, sosial media, link) — TIRU tata letak header/footer di
  design/home.png tapi warna Victoria.
- Halaman placeholder: / , /promo , /produk , /education , /login , /register.
Referensi visual header/nav & tombol ada di design/home.png dan design/login.png.
Acceptance: nuxt dev jalan, design tokens konsisten, navbar+footer tampil di semua halaman.
```

## P1 — Homepage  ✅ SELESAI
**Asset:** `design/home.png`, `design/home-investasisekarang-filterkolomkategori-klikbeli-detailbeli-klikbeli.gif`
```
[TEMPEL HEADER KONTEKS]

Tugas P1: Bangun HOMEPAGE (/) meniru struktur design/home.png (hero, "Produk Investasi",
tabel kinerja NAV reksadana, section "Kenapa Victoria" dengan 4 keunggulan + ikon,
banner CTA "Investasi Sekarang", section Edukasi/artikel, grid "Manajer Investasi Pilihan",
footer). Tampilan pakai brand Victoria (gradient hero navy→biru, aksen emas, ilustrasi
3D finance, kartu rounded, micro-interaction).
- Tabel kinerja NAV: kolom Reksadana, Jenis, NAV/Unit, AUM, 1hr/1bln/3bln/YTD %, tombol Beli.
  Nilai naik = teal ▲, turun = merah ▼ (lihat pola di gif).
- Ambil data dari sekuritas-api (GET /api/products). Sediakan fallback data dummy.
Referensi flow "investasi sekarang → filter → beli" ada di gif yang disebut di atas.
Acceptance: homepage responsive, data produk tampil, semua CTA mengarah benar.
```

## P2 — Login, Register User ID, & email aktivasi  ✅ SELESAI
**Asset:** `design/login.png`, `design/register.png`, `design/registeruserid.png`, `design/login-register-registeruseriddulu-buatemailpassword-klikregister-isidata-dapatemail-kliklinkemailaktivasi-loginkembali-isiverifikasidll.gif`, `design/Registration CGS International.eml`
```
[TEMPEL HEADER KONTEKS]

Tugas P2: Bangun autentikasi web meniru flow di gif (register User ID dulu → buat
email+password → klik Register → terima email → klik link aktivasi → login kembali).
- /login : form "Masuk ke akun Victoria" (User ID + Password + show/hide + Lupa password
  + link Register). Tiru layout 2-kolom di design/login.png (kiri form, kanan ilustrasi),
  warna Victoria. Panggil POST /api/auth/login.
- /register : form User ID + Password (min 8, 1 kapital 1 angka) + Konfirmasi + checkbox
  "Setuju Syarat & Ketentuan" + tombol Daftar. Tiru design/register.png. Validasi seperti
  di screenshot. Panggil POST /api/auth/register.
- Setelah register, backend kirim EMAIL "Link Aktivasi". Buat template email HTML Victoria
  berdasarkan isi design/Registration CGS International.eml (teks dwibahasa ID/EN, tombol
  "Link Aktivasi" → https://<web>/aktivasi?token=...). Ganti brand CGS → Victoria Sekuritas.
- /aktivasi : verifikasi token → aktifkan akun → arahkan ke login.
Acceptance: alur register→email→aktivasi→login jalan end-to-end (email boleh mailtrap/log).
```

## P3 — Online Account Opening step 1: Verifikasi + eKYC  ✅ SELESAI
**Asset:** `design/registeruserid.png`, `design/isianregisteruserid.png`, `design/izinkanakseskamera.png`, `design/isiverifikasi-datapribadi-datapekerjaan-informasitambahan-persyaratan_ketentuan.gif`
```
[TEMPEL HEADER KONTEKS]

Tugas P3: Bangun halaman "Pembukaan Rekening Online" dengan STEPPER 5 langkah
(Verifikasi → Data Pribadi → Data Pekerjaan → Informasi Tambahan → Persyaratan & Ketentuan)
— tiru stepper & tata letak di design/registeruserid.png / isianregisteruserid.png, warna
Victoria (garis progress emas, angka aktif biru).
Fokus LANGKAH 1 — VERIFIKASI:
- Kewarganegaraan (Indonesia/Asing), Verifikasi E-KTP (kotak scan + "Ambil Foto E-KTP" +
  tombol kamera), Kategori Akun, Nama Sales, No. E-KTP, Nama Lengkap, Nama Ibu Kandung,
  Jenis Kelamin, Tempat/Tanggal Lahir, Rekening Tabungan (pilih bank + no rek),
  Rekening Dana Nasabah (RDN). Tombol "Simpan Draf" & "Berikutnya".
- eKYC: minta izin kamera (tiru modal "Izinkan Akses Kamera" di design/izinkanakseskamera.png),
  ambil foto KTP, jalankan OCR KTP GRATIS (pakai Tesseract.js / ML Kit web / library gratis)
  untuk auto-isi No. KTP & Nama. Simpan foto ke API (POST /api/kyc/upload).
Referensi pengisian semua langkah ada di gif isiverifikasi-... .
Acceptance: step 1 tervalidasi, foto KTP terkirim, OCR mengisi field otomatis, draft tersimpan.
```

## P4 — Online Account Opening step 2–4  ✅ SELESAI
**Asset:** `design/lanjutaninformasipekerjaan-informasitambahan-persyaratan&ketentuan.gif`, `design/isiverifikasi-datapribadi-datapekerjaan-informasitambahan-persyaratan_ketentuan.gif`
```
[TEMPEL HEADER KONTEKS]

Tugas P4: Lanjutkan stepper pembukaan rekening — LANGKAH 2 Data Pribadi (alamat KTP &
domisili, agama, status kawin, pendidikan, no HP, email, dsb), LANGKAH 3 Data Pekerjaan
(pekerjaan, bidang usaha, jabatan, penghasilan/tahun, sumber dana, nama & alamat kantor),
LANGKAH 4 Informasi Tambahan (tujuan investasi, profil risiko, pernyataan FATCA/beneficial
owner, dll). Tiru urutan & field yang muncul di kedua gif di atas. Simpan tiap langkah ke
API (buat/panggil endpoint yang sesuai; sinkron dengan tabel kyc/risk_profiles). Validasi
per langkah, tombol Kembali/Simpan Draf/Berikutnya, warna Victoria.
Acceptance: langkah 2–4 tersimpan bertahap, bisa lanjut/mundur tanpa kehilangan data.
```

## P5 — Online Account Opening step 5: Persyaratan + Tanda Tangan Digital (Privy)  ✅ SELESAI
**Asset:** `design/lanjutanpersyaratan&ketentuan.gif`, `design/Complete Account.eml`
```
[TEMPEL HEADER KONTEKS]

Tugas P5: LANGKAH 5 "Persyaratan & Ketentuan" — tampilkan dokumen S&K + pernyataan yang
harus disetujui (tiru gif lanjutanpersyaratan&ketentuan.gif), lalu TANDA TANGAN DIGITAL:
- Integrasi Privy (mode sandbox) untuk tanda tangan dokumen pembukaan rekening. Jika Privy
  belum tersedia, sediakan fallback canvas signature (gambar tanda tangan) + simpan ke API.
- Setelah submit final (POST /api/kyc/submit): generate/simulasikan SID via S-Invest (isi
  tabel sid_data), set status KYC = "menunggu verifikasi".
- Backend kirim EMAIL "Complete Account": dokumen pembukaan rekening untuk ditandatangani —
  buat template HTML Victoria dari design/Complete Account.eml (dwibahasa, placeholder
  %link_cgs%/%link_pdf% → tautan dokumen Victoria). Ganti brand & alamat CGS → Victoria.
- Halaman sukses "Pendaftaran Selesai".
Acceptance: submit final jalan, tanda tangan tersimpan, SID tergenerate, email terkirim.
```

## P6 — Halaman Produk (list + filter)  ✅ SELESAI
**Asset:** `design/pilihprodukreksadana.png`, `design/home-produk-listobligasi-haruslogin_daftar.gif`
```
[TEMPEL HEADER KONTEKS]

Tugas P6: Halaman /produk "Pilih Produk Reksa Dana" — tiru design/pilihprodukreksadana.png:
tab kategori (Semua, Pasar Uang, Pendapatan Tetap, Saham, Indeks, Campuran, Syariah,
Endowment Fund, Terproteksi), tombol Filter & Kolom, Search, tabel (Reksa Dana + MI, tombol
Beli, Jenis, NAV/UP, Dana Kelolaan, 1bln %, 1thn %), pagination. Nilai naik teal ▲ / turun
merah ▼. Warna Victoria, kartu/tabel modern. Data dari GET /api/products (dengan query
filter/kategori/sort/search). Klik "Beli" saat belum login → arahkan ke login/daftar
(lihat gif listobligasi-haruslogin_daftar).
Acceptance: filter/kategori/search/sort/pagination jalan, gating login untuk Beli benar.
```

## P7 — Detail Produk Reksadana  ✅ SELESAI
**Asset:** `design/home-kliktombolbelireksadana-detailreksadana.png`, `design/detailreksadana-klikbeli-haruslogin.gif`
```
[TEMPEL HEADER KONTEKS]

Tugas P7: Halaman /produk/[id] detail reksadana — tiru design/home-kliktombolbelireksadana-
detailreksadana.png: kartu kiri (nama, MI, jenis, tgl peluncuran, min pembelian/penjualan,
bank kustodian, tombol Beli), "Lihat Dokumen" (Prospektus, Fund Fact Sheet), "Ketentuan";
kanan: kartu NAV/Unit + Dana Kelolaan + Unit Penyertaan, grafik "Performa NAV" (toggle
1D/1M/3M/1Y/3Y/5Y) & grafik "Pertumbuhan Dana Kelolaan". Pakai chart library (mis. Chart.js/
ApexCharts) warna Victoria (garis biru, area gradient). Data: GET /api/products/{id} &
/api/products/{id}/nav-history. Klik Beli belum login → login (lihat gif).
Acceptance: detail + 2 grafik tampil, toggle periode jalan, tombol Beli benar.
```

## P8 — Bandingkan Reksadana & Manajer Investasi  ✅ SELESAI
**Asset:** `design/perbandinganreksadana.png`, `design/perbandinganmanajerinvestasi.png`, `design/promo-produk-reksadana-bandingkanreksadana-pilih3reksadana-klikbuttonbandingkan-munculhasilperbandinganreturnnav.gif`, `design/menumanajerinvestasi-munculhasilperbandinganmanajerinvestasi-pilihdarisampai-klikcekperbandingan.gif`, `design/daftarreksadana_listreksadana-listmanajerinvestasi-klik3manajerinvestasi-klikbuttonbandingkan.gif`
```
[TEMPEL HEADER KONTEKS]

Tugas P8: Fitur BANDINGKAN.
1) Bandingkan Reksadana (tiru design/perbandinganreksadana.png + gif pilih3reksadana...):
   tabel dengan checkbox (maks 3), tombol "Bandingkan", lalu tampil "Perbandingan Return NAV"
   (legend warna per produk) + grafik "Performa NAV" & "Pertumbuhan Dana Kelolaan".
2) Bandingkan Manajer Investasi (tiru design/perbandinganmanajerinvestasi.png + gif
   menumanajerinvestasi...): pilih MI, rentang "dari–sampai", tombol "Cek Perbandingan".
Data dari GET /api/products & /api/products/managers. Warna Victoria, grafik multi-series.
Acceptance: pilih ≤3, tombol bandingkan menghasilkan grafik & tabel perbandingan yang benar.
```

## P9 — Promo/Event + link referral  ✅ SELESAI
**Asset:** `design/promo.png`, `design/promo-reksadana-daftarreksadana:listreksadana.gif`, `design/promo-education-artikel-listartikel.gif`
```
[TEMPEL HEADER KONTEKS]

Tugas P9: Modul PROMO/EVENT (fitur andalan untuk menarik registrasi).
- /promo : daftar promo aktif (kartu event: judul, banner, periode, benefit, tombol "Ikuti").
  Jika kosong, tampilkan empty-state seperti design/promo.png ("Belum ada promo berlangsung")
  + banner CTA "Investasi Sekarang". Warna Victoria.
- /promo/[kode] : LANDING PAGE per-event dari link khusus (mis. victoria.co.id/promo/RAMADAN25).
  Tampilkan detail benefit + tombol Daftar yang MEMBAWA kode event ke proses registrasi
  (query ?ref=KODE), agar pendaftaran via link tercatat & dapat promo/reward.
- Saat register/pembukaan rekening, simpan kode event → POST /api/events/register &
  /api/events/{code} (endpoint sudah ada). Tampilkan leaderboard bila relevan.
Referensi navigasi promo→reksadana / promo→education ada di 2 gif di atas.
Acceptance: link /promo/{kode} men-track pendaftaran, benefit tampil, data masuk API events.
```

## P10 — Education / Artikel  ✅ SELESAI
**Asset:** `design/listartikel.png`, `design/detailartikel.png`, `design/home-klikartikellihatsemua-klikartikel-detailartikel.gif`, `design/promo-education-artikel-listartikel.gif`
```
[TEMPEL HEADER KONTEKS]

Tugas P10: Halaman /education — list artikel (grid kartu: thumbnail, tag/kategori, tanggal,
judul, "Baca Selengkapnya") tiru design/listartikel.png; dan /education/[slug] detail artikel
(hero image, judul, tanggal, konten, artikel terkait) tiru design/detailartikel.png. Warna
Victoria, tipografi enak dibaca. Data: GET /api/articles & /api/articles/{slug}. Flow
"home → lihat semua → klik artikel → detail" seperti gif klikartikellihatsemua...
Acceptance: list + detail artikel tampil dari API, kategori & tanggal benar, responsive.
```

## P11 — Beli reksadana + Pembayaran  ✅ SELESAI
**Asset:** `design/home-investasisekarang-filterkolomkategori-klikbeli-detailbeli-klikbeli.gif`, `design/home-klikbeli-detailreksadana-klikbeli-masukkeappvictoriasekuritas-uploadpembayaran_viapaymentgatewa.gif`, `design/home-klikbeli-detailreksadana-klikbeli-mengarahkepembelian-tpgapunyaakun-tapipakaiinvesnowkarenahamp.gif`
```
[TEMPEL HEADER KONTEKS]

Tugas P11: Flow BELI & BAYAR (untuk user login & KYC approved).
- Dari detail produk → "Beli" → form pembelian (nominal, sumber dana RDN, ringkasan,
  setuju ketentuan) → konfirmasi. Tiru gif home-investasisekarang...klikbeli-detailbeli.
- Pembayaran: dukung 2 cara seperti gif — (a) via payment gateway (Midtrans/Xendit sandbox),
  (b) upload bukti transfer manual. POST /api/transactions/subscribe + /api/payment/confirm
  (endpoint sudah ada). Untuk pengguna tanpa akun/pengarahan ke app: tampilkan CTA sesuai
  gif masukkeappvictoriasekuritas... (arahkan ke aplikasi mobile / lanjut di web).
Acceptance: order tercatat, pembayaran sandbox sukses / upload bukti tersimpan, status update.
```

## P12 — Status Transaksi  ✅ SELESAI
**Asset:** `design/transaksi-dalamproses-selesai-listselesai.gif`
```
[TEMPEL HEADER KONTEKS]

Tugas P12: Halaman "Transaksi" (dashboard nasabah) — daftar transaksi dengan status
"Dalam Proses" / "Selesai" (tab/filter), detail transaksi, timeline status. Tiru gif
transaksi-dalamproses-selesai-listselesai.gif. Data: GET /api/transactions &
/api/transactions/{id}. Badge status warna Victoria (proses=amber, selesai=teal).
Acceptance: list & detail transaksi tampil, filter status jalan, timeline benar.
```

---

# BAGIAN B — BACKEND API (`sekuritas-api`)

## P13 — Email templates & integrasi  ✅ SELESAI
**Asset:** `design/Registration CGS International.eml`, `design/Complete Account.eml`
```
[TEMPEL HEADER KONTEKS]

Tugas P13 (repo sekuritas-api): Buat 2 template email Blade/Markdown Victoria:
1) "Registrasi Victoria Sekuritas" — konfirmasi pendaftaran + tombol Link Aktivasi.
   Basis teks dwibahasa ID/EN dari design/Registration CGS International.eml, brand → Victoria.
2) "Lengkapi Akun / Complete Account" — dokumen pembukaan rekening untuk ditandatangani
   (Pembukaan Rekening Efek + RDN + form W8/W9/CRS), basis design/Complete Account.eml,
   alamat/kontak → Victoria. Pakai placeholder link dokumen.
Kirim otomatis pada event register & submit KYC. Konfigurasi mailer (log/mailtrap untuk dev).
Acceptance: kedua email terkirim pada event yang tepat, isi & tombol benar, brand Victoria.
```

## P14 — Integrasi eKYC, Privy, S-Invest (adapter)  ✅ SELESAI
**Asset:** `design/izinkanakseskamera.png`, `design/isiverifikasi-datapribadi-datapekerjaan-informasitambahan-persyaratan_ketentuan.gif`
```
[TEMPEL HEADER KONTEKS]

Tugas P14 (repo sekuritas-api): Buat layanan/adapter integrasi (pattern interface + driver
"sandbox/free" agar mudah diganti ke provider resmi):
- EkycService: verifikasi KTP + wajah. Driver default gratis (OCR/liveness sederhana),
  interface siap untuk Verihubs/Privy. Endpoint POST /api/kyc/ekyc.
- SignatureService (Privy): buat dokumen + minta tanda tangan (driver sandbox + fallback
  simpan gambar tanda tangan). Endpoint POST /api/kyc/sign.
- SinvestService: generate/registrasi SID (driver simulasi mengisi tabel sid_data), interface
  siap untuk API KSEI resmi. Panggil saat submit KYC.
Semua konfigurasi via .env, dokumentasikan di README. Jaga keamanan data KTP (enkripsi/at rest).
Acceptance: 3 service jalan di mode sandbox, endpoint teruji, mudah di-swap ke driver resmi.
```

---

# BAGIAN C — CMS ADMIN (`sekuritas-cms`)

## P15 — Rebrand CMS ke Victoria + modul Promo/Event  ✅ SELESAI
**Asset:** `design/home.png` (acuan warna brand), `design/promo.png`
```
[TEMPEL HEADER KONTEKS]

Tugas P15 (repo sekuritas-cms): 
1) Ganti tema dari teal (#009688) ke brand Victoria (navy/biru + emas) di tailwind.config.ts,
   sidebar, tombol, badge, StatsCard, DataTable, StatusBadge. Konsisten & modern.
2) Sempurnakan modul Promo/Event admin (API events sudah ada): buat/edit event (judul, banner,
   kode/link referral, periode, benefit/reward, aktif-nonaktif), lihat leaderboard & export
   peserta. Ini yang menggerakkan promo di web depan (lihat P9). Preview empty-state seperti
   design/promo.png.
Acceptance: seluruh CMS berwarna Victoria, CRUD event + leaderboard + export jalan.
```

## P16 — CMS: Verifikasi KYC & manajemen Produk/NAV  ✅ SELESAI
**Asset:** `design/pilihprodukreksadana.png`, `design/home-kliktombolbelireksadana-detailreksadana.png`
```
[TEMPEL HEADER KONTEKS]

Tugas P16 (repo sekuritas-cms): 
1) Halaman Verifikasi KYC: daftar pengajuan, detail (data + foto KTP + tanda tangan + SID),
   tombol Approve/Reject + alasan. Pakai API /api/cms/kyc/*.
2) Manajemen Produk & NAV: CRUD produk reksadana (field seperti kartu detail di
   design/home-kliktombolbelireksadana-detailreksadana.png: MI, jenis, min pembelian, bank
   kustodian, dokumen), update NAV harian + update NAV massal (/api/cms/products/nav-bulk).
   Field & kategori selaras halaman publik (design/pilihprodukreksadana.png).
Acceptance: admin bisa verifikasi KYC end-to-end & kelola produk/NAV; data muncul di web depan.
```

---

# BAGIAN D — MOBILE (`sekuritas-mobile`)

## P17 — Rebrand mobile + selaraskan flow  ✅ SELESAI
**Asset:** `design/home-klikbeli-detailreksadana-klikbeli-masukkeappvictoriasekuritas-uploadpembayaran_viapaymentgatewa.gif`, `design/isiverifikasi-datapribadi-datapekerjaan-informasitambahan-persyaratan_ketentuan.gif`
```
[TEMPEL HEADER KONTEKS]

Tugas P17 (repo sekuritas-mobile, Flutter): 
1) Update app_colors.dart & app_theme.dart ke brand Victoria (navy/biru + emas), ganti nama
   app dari "sekuritas_demo" → "Victoria Sekuritas", ikon & splash.
2) Selaraskan flow dengan web & video: onboarding → invitation/kode promo → register/OTP/PIN
   → KYC (scan KTP + tanda tangan) → home → produk/detail → beli → BAYAR (payment gateway /
   upload bukti, seperti gif masukkeappvictoriasekuritas...uploadpembayaran) → portofolio →
   transaksi. Semua screen sudah ada di lib/features — rapikan UI ke brand Victoria &
   sambungkan ke sekuritas-api (dio, base URL dari env).
3) eKYC mobile: OCR KTP pakai google_mlkit (gratis) untuk auto-isi.
Acceptance: app rebrand Victoria, flow beli+bayar jalan ke API, build APK sukses.
```

## P18 — Finalisasi & QA lintas platform  ⚠️ SEBAGIAN (kode siap; QA end-to-end belum dijalankan penuh)
**Asset:** semua `.gif` di `design/` (sebagai checklist flow)
```
[TEMPEL HEADER KONTEKS]

Tugas P18: QA menyeluruh. Bandingkan tiap flow web & mobile dengan gif di folder design/
(satu per satu) — pastikan urutan langkah, field, dan hasil SAMA seperti CGS iTradeFund,
tapi tampilan Victoria. Perbaiki inkonsistensi warna/spacing/teks. Jalankan build web
(nuxt build), API (php artisan test), mobile (flutter build apk). Buat README singkat
cara menjalankan tiap repo + daftar env yang dibutuhkan. Commit & push semua.
Acceptance: 3–4 repo build sukses, flow cocok dengan gif, README lengkap.
```

---

## Ringkasan urutan
`P0 → P1 → P2 → P3 → P4 → P5` (web + account opening) → `P6 → P7 → P8` (produk) →
`P9 → P10` (promo & edukasi) → `P11 → P12` (beli/bayar/transaksi) →
`P13 → P14` (API email & integrasi) → `P15 → P16` (CMS) → `P17` (mobile) → `P18` (QA).

> Tiap prompt sudah menyebut file asset spesifik di `design/`. Saat mengerjakan di Claude,
> buka file `.png`/`.gif`/`.eml` yang disebut sebagai acuan visual/flow. Kerjakan berurutan.
