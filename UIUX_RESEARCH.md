# UI/UX Research — Victoria Sekuritas vs CGS iTradeFund

Menjawab bagian *UI/UX Research* di `MASTER_PROMPT_EKYC_VICTORIA_SEKURITAS.md`. Benchmark = CGS iTradeFund (referensi **flow & best practice**, bukan untuk ditiru visualnya). Target = brand **Victoria** yang lebih modern/eye-catching.

## 1. Information Architecture (IA)
| Area | CGS iTradeFund | Victoria (implementasi) |
|------|----------------|-------------------------|
| Publik | Home, Promo, Produk, Education, Masuk/Daftar | Home, Reksa Dana, Manajer Investasi, **Bandingkan**, Promo, Artikel, Masuk/Daftar |
| Account opening | 5 langkah (Verifikasi→Data Pribadi→Pekerjaan→Info Tambahan→S&K) | **eKYC otomatis** (`/pembukaan-rekening/ekyc`) + **Data** (`/pembukaan-rekening/data`, 3 langkah) |
| Nasabah | Portofolio, Transaksi | Dashboard, Portofolio, Transaksi, Profil |
| Admin | (terpisah) | CMS: Dashboard, KYC, Users, Produk, Artikel, **Event & Promo**, Transaksi, Reports |

Perbaikan Victoria: menambah **Bandingkan** dan **eKYC otomatis** (OCR/liveness) yang mempersingkat 5 langkah manual CGS.

## 2. User Journey (nasabah)
`Landing → Daftar (OTP) → eKYC (KTP→OCR→selfie→liveness→face→ttd→verifikasi) → Lengkapi Data → (Ops approve + SID) → Beli reksadana → Bayar → Portofolio`. Titik friksi CGS (isi manual panjang) dipangkas dengan **OCR auto-fill** + skoring otomatis.

## 3. Navigation
- **Web publik**: top-nav sticky + mobile nav row (chip). CTA "Daftar" menonjol.
- **Web nasabah**: sidebar (desktop) + bottom/drawer (mobile).
- **CMS**: sidebar kolaps + breadcrumb judul halaman.
- Prinsip: maks 1 aksi utama per layar; stepper untuk alur panjang (eKYC, data, transaksi).

## 4. Design System (Victoria — final)
- **Warna brand (dari logo)**: primary merah `#A40001` (hover `#7D0001`), aksen rose `#C67177`/`#D59997`, netral hangat krem `#F0F3EC` / paper `#FFFDFC` / `#E2DAD3` / `#D2D7D3`, teks `#1A1A1A`.
- **Semantik**: naik/sukses hijau `#10B981`, turun/error merah `#EF4444`, warning `#F59E0B`.
- **Gradient hero**: `135deg #7D0001 → #A40001 → #C67177`. Shadow di-tint merah.
- Token dipusatkan (tailwind `primary/accent` + `AppColors`) → ganti brand = 1 tempat.

## 5. Typography
- Heading: **Plus Jakarta Sans** (display, extrabold). Body: **Inter**.
- Mobile: Poppins (existing). Angka finansial: tabular-nums.
- Skala: hero 32–44, judul section 18–24, body 13–15, caption 11–12.

## 6. Color Palette (CSS variables usulan)
```css
:root{
  --vs-red:#A40001; --vs-red-dark:#7D0001; --vs-rose:#C67177; --vs-rose-light:#D59997;
  --vs-cream:#F0F3EC; --vs-paper:#FFFDFC; --vs-sand:#E2DAD3; --vs-mist:#D2D7D3; --vs-ink:#1A1A1A;
  --up:#10B981; --down:#EF4444; --warn:#F59E0B;
}
```

## 7. Components (dipakai konsisten)
Button (primary/secondary/ghost), Card (radius 16–20, shadow lembut), Badge (naik/turun/status), Input/Select, Stepper, Tabel NAV (▲/▼ warna), Chart NAV (SVG), Modal/ConfirmModal, StatsCard, DataTable, StatusBadge, Signature pad.

## 8. Accessibility
- Kontras: teks utama `#1A1A1A` di atas krem → AA. Tombol putih di atas merah `#A40001` → AA.
- Target sentuh ≥ 44px; fokus ring (`focus:ring`) pada input/tombol.
- Label eksplisit di form; status error teks + warna (bukan warna saja).
- Alt text pada logo/ilustrasi; urutan heading logis.
- Rekomendasi lanjutan: uji dengan screen reader, `prefers-reduced-motion` untuk animasi.

## 9. Desktop & Mobile UX
- Desktop: 2 kolom (form + ilustrasi) pada auth; grid katalog; tabel penuh.
- Mobile: single-column, kamera via `capture` (web) / `image_picker` (app), bottom nav.
- Konten lebar (tabel/chart) scroll horizontal dalam kontainer sendiri.

## 10. Empty / Error / Loading / Success State
| State | Pola |
|-------|------|
| Empty | Ilustrasi/ikon + pesan + CTA (mis. Promo kosong → "Belum ada promo", tombol Investasi) |
| Loading | Skeleton shimmer (kartu/tabel), spinner tombol, progress stepper |
| Error | Banner merah lembut + pesan actionable; toast untuk aksi cepat |
| Success | Badge/skor hijau (mis. hasil eKYC), redirect + konfirmasi |

## 11. Cara ekstrak aset brand (bila perlu, via DevTools)
1. Buka situs → DevTools → Elements → pilih elemen brand → **Computed → color/background** (nilai HEX/RGB).
2. **Sources / Network**: filter `Img`/`Font` untuk unduh logo/favicon/font.
3. Warna Victoria final sudah diekstrak dari **logo** (`design/asset+logo/…logo5.png` = ornamen merah) → lihat §4.

## 12. Kesimpulan
Victoria mempertahankan **flow** CGS yang sudah teruji (stepper account opening, tabel NAV, promo) namun mengungguli pada: **eKYC otomatis** (OCR/liveness/face), fitur **Bandingkan**, sistem **promo referral + leaderboard**, dan **design system tunggal** berbasis brand merah Victoria yang konsisten di web/CMS/mobile/email.
