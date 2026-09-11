# Design System Referensi — danapathi.co.id

Diekstrak 2026-09-11 dari CSS asli situs (`assets/css/danapathi.css` + 7 blok `<style>` inline)
lalu dicek ulang terhadap nilai *computed* di browser (1440px & 390px). Screenshot referensi:
`design/referensi-danapathi/` (desktop-hero, desktop-full, mobile-full, halaman-reksadana).

> Danapathi = **Manajer Investasi** (reksa dana), bukan broker. Danapathi adalah **klien** untuk versi
> branch `danapathi` (logo & foto mereka boleh dipakai di situ). Untuk brand/klien lain, ambil hanya
> **gaya visual** — jangan salin logo, foto, atau teks Danapathi.
> Situs dibangun dengan Bootstrap 5 + Bootstrap Icons (tanpa Tailwind/framework JS).

**Kesan umum:** terang & lapang. Putih dominan, **navy** untuk semua teks/judul/tombol utama,
**hijau** sebagai aksen kecil (CTA "Portal Investor", baris kedua judul hero, angka profit).
Kartu & panel sudut sangat bulat (22–34px) dengan bayangan navy yang nyaris tak terlihat.
Foto asli (gedung kaca biru + pepohonan), ikon outline navy di tile pucat.

---

## 1. Palet warna inti (5 warna yang paling menentukan)

| Peran | HEX | RGB | Dipakai untuk |
|---|---|---|---|
| **Navy judul** | `#00214A` | 0, 33, 74 | h1–h6, link navbar, warna logo |
| **Navy utama (tombol)** | `#14365F` | 20, 54, 95 | tombol primary hero, judul section, panel simulator, tab aktif |
| **Hijau aksen** | `#198754` | 25, 135, 84 | CTA navbar, baris hijau judul hero, garis eyebrow, angka profit, hover |
| **Teks body** | `#617286` | 97, 114, 134 | paragraf & teks umum |
| **Latar lembut** | `#F8FAFC` | 248, 250, 252 | tile benefit, panel ringkasan, akhir gradient section |

## 2. Palet lengkap

| Nama / peran | HEX | RGB | Keterangan |
|---|---|---|---|
| Navy hero | `#082C53` | 8, 44, 83 | baris navy judul hero (weight 800) |
| Navy teks kartu | `#16355F` | 22, 53, 95 | teks produk/FAQ, tombol "Profil Perusahaan", isi hover tombol outline |
| Navy gelap | `#0F2F5F` | 15, 47, 95 | tab aktif (subhalaman), angka NAB |
| Navy link | `#234A74` | 35, 74, 116 | `--danapathi-primary`: link, pagination, legal |
| Gradient panel kepercayaan | `#0F3D75 → #1F4F87` | — | 135°, panel "Manajer Investasi Profesional" |
| Gradient panel simulator | `#14365F → #0F2F55` | — | 180° |
| Footer bar | `#1A4978` | 26, 73, 120 | bar copyright paling bawah |
| Hijau hover | `#157347` | 21, 115, 71 | hover tombol hijau |
| Hijau logo | `#147824` | 20, 120, 36 | daun & tulisan "ASSET MANAGEMENT" |
| NAB naik | `#1F8A5B` | 31, 138, 91 | ▲ perubahan harian |
| NAB turun | `#D84B4B` | 216, 75, 75 | ▼ perubahan harian |
| Peringatan | `#EBBA45` | 235, 186, 69 | badge "Hati-Hati Penipuan" |
| Teks deskripsi | `#5F7084` | 95, 112, 132 | deskripsi section |
| Teks muted | `#64748B` | 100, 116, 139 | label, tanggal |
| Teks soft | `#475569` | 71, 85, 105 | teks legal footer |
| Teks faint | `#94A3B8` | 148, 163, 184 | placeholder |
| Border | `#E5E7EB` | 229, 231, 235 | garis umum |
| Border input | `#DBE2EA` | 219, 226, 234 | input form |
| Border kartu (tint navy) | `rgba(15,53,103,.06)` | — | hampir semua kartu |
| Latar halaman | `#F9FAFB` | 249, 250, 251 | body |
| Latar hero | `#F5F7FB` | 245, 247, 251 | slider hero |
| Putih | `#FFFFFF` | — | header, kartu, mayoritas section |

**Badge risiko (halaman reksa dana):** Rendah `#198754` / bg `rgba(25,135,84,.08)` ·
Sedang `#0D6EFD` / `.08` · Menengah-tinggi `#B78103` / `rgba(255,193,7,.15)` · Tinggi `#DC3545` / `.08`.

## 3. Tipografi

| Token | Nilai |
|---|---|
| Font judul | **Plus Jakarta Sans** (400/500/600/700; 800 dipakai di hero) |
| Font body | **Inter** (400–700) |
| Ukuran dasar | 16px (turun ke 15.5 → 15 → 14.5 → 14px di layar kecil) |
| Line-height body | 1.7 (paragraf 1.85–1.95 — sangat lapang) |
| Hero h1 | `clamp(32px, 5vw, 68px)` · 700 (baris navy 800, baris hijau 600) · lh 1.08 · letter-spacing −1px |
| Section h2 | 44px · 700 · lh 1.04–1.14 · letter-spacing **−0.04 s/d −0.06em** (34px ≤767, 28px ≤575) |
| h3 | 30px · 700 · letter-spacing −0.04em |
| Angka NAB | 28px · 700 · letter-spacing −0.045em · `#102F55` |
| Deskripsi hero | 17px · lh 1.7 · `#5F6F7F` |
| Eyebrow / pill | 10–12px · 700 · UPPERCASE · letter-spacing 0.1–0.16em |
| Link navbar | 15px · 600 |
| Tombol | 13–16px · 600 |

> Kebetulan web Victoria **sudah** memakai Plus Jakarta Sans + Inter — tinggal sesuaikan ukuran & letter-spacing.

## 4. Radius, bayangan, spacing

| Elemen | Radius | | Bayangan | Nilai |
|---|---|---|---|---|
| Pill | 999px | | Kartu produk | `0 2px 10px rgba(16,47,85,.025)` |
| CTA navbar | 50px | | Panel | `0 4px 18px rgba(15,53,103,.025)` |
| Tombol kecil outline | 12px | | Box besar | `0 10px 32px rgba(15,53,103,.03)` |
| Tombol utama | 18px | | Trust strip | `0 12px 40px rgba(15,23,42,.08)` |
| Input | 16px | | Hover kartu | `0 14px 34px rgba(16,47,85,.06)` |
| Kartu produk | 22px | | CTA hijau | `0 8px 18px rgba(25,135,84,.25)` |
| Trust strip | 28px | | | |
| Panel besar | 30px | | | |
| Box simulator / gambar hero | 34px | | | |

Hover: `translateY(-2px … -4px)`, transisi `.25s ease`. Container 1360px (hero 1440px).
Section `padding: 40px 0`; header section `mb 42–52px`; padding kartu 24px, panel 36–40px; gap grid 14–24px.

## 5. Tombol

| Tombol | Latar | Teks | Border | Radius | Ukuran | Hover |
|---|---|---|---|---|---|---|
| Primary (hero) | `#14365F` | putih | – | 18px | px 30, tinggi 54px, 16px/600 | naik 2px |
| Secondary (hero) | `rgba(255,255,255,.84)` | `#14365F` | 1px `rgba(20,54,95,.08)` | 18px | sama | border `#0F3D75` |
| CTA navbar | `#198754` | putih | – | 50px | 10×22px, tinggi 42px | `#157347` + bayangan hijau |
| Solid navy | `#16355F` | putih | – | 18px | 13×22px, 14px | berubah hijau `#198754` |
| Outline kecil | putih | `#16355F` | 1px `rgba(16,47,85,.08)` | 12px | 12×22px, 13px + ikon panah | isi navy, teks putih |

## 6. Struktur halaman (homepage, urut)
1. **Header** putih sticky (±102px): logo kiri · menu (Tentang Kami ▾ mega-menu, Produk & Layanan ▾, Publikasi, Pengaduan, Kontak) · pill hijau **Portal Investor** · ID/EN.
2. **Hero slider**: foto gedung kaca di kanan, gradient putih memudar dari kiri; pill eyebrow · judul 2 warna (navy lalu hijau) · deskripsi · 2 tombol. Di bawahnya **trust strip** 4 kolom (panel gradient navy "Manajer Investasi Profesional" + OJK + Mitra Distribusi + Bank Kustodian).
3. **Produk unggulan**: judul + "Lihat Semua Produk" di kanan; 5 kartu reksa dana (pill kategori, nama, NAB/Unit, perubahan ▲/▼); keterangan tanggal NAB.
4. **Tentang + FAQ**: 2 panel putih besar (kiri: teks + grid 2×2 benefit + tombol navy; kanan: accordion 4 item).
5. **Simulasi investasi**: 1 box 3 kolom (panel info navy · form tab Sekali/Rutin/Target · ringkasan dgn angka profit hijau).
6. **Artikel/berita**: carousel artikel utama + sidebar 3 artikel terbaru.
7. **Mitra & ekosistem**: grid logo agen penjual, bank kustodian, regulator.
8. **Footer** minimal: bar legal putih (pernyataan OJK) + bar `#1A4978` copyright & sosmed.
9. Elemen melayang: pill WhatsApp "Hubungi Kami", pill kuning "Hati-Hati Penipuan", scroll-to-top, banner cookie.

**Subhalaman:** banner foto navy gelap + eyebrow putih 68% + judul putih 42px di tengah + breadcrumb.
Halaman reksa dana: tab kategori berbentuk pill (aktif navy `#0F2F5F`), kartu produk lebar radius 28px + badge risiko berwarna.

---

## 7. Siap pakai — Tailwind (`sekuritas-frontend/tailwind.config.ts`)
Kode Victoria sudah memakai token `primary` / `accent` / `bg-brand-gradient`, jadi ganti tema cukup
mengganti nilai token (kelas di halaman ikut berubah):

```ts
const navy = { 50:'#EEF3F9', 100:'#D9E3EF', 200:'#B3C6DD', 300:'#8AA5C6', 400:'#4F6F97',
  500:'#234A74', 600:'#14365F', 700:'#0F2F5F', 800:'#082C53', 900:'#00214A' }
const green = { 50:'#E9F5EF', 100:'#CDEBDC', 200:'#9FD6BB', 300:'#6CBF96', 400:'#3AA672',
  500:'#198754', 600:'#157347', 700:'#146B40', 800:'#0F5533', 900:'#0B4027' }

theme.extend = {
  colors: {
    primary: navy, accent: green, teal: navy,
    ink: { DEFAULT:'#617286', desc:'#5F7084', muted:'#64748B' },
    surface: { page:'#F9FAFB', soft:'#F8FAFC', hero:'#F5F7FB' },
    up:'#1F8A5B', down:'#D84B4B', warn:'#EBBA45',
  },
  fontFamily: { sans:['Inter','sans-serif'], display:['"Plus Jakarta Sans"','sans-serif'] },
  borderRadius: { btnsm:'12px', btn:'18px', input:'16px', card:'22px', panel:'30px', box:'34px' },
  boxShadow: {
    card:'0 2px 10px rgba(16,47,85,.025)', 'card-hover':'0 14px 34px rgba(16,47,85,.06)',
    soft:'0 4px 18px rgba(15,53,103,.025)', strip:'0 12px 40px rgba(15,23,42,.08)',
  },
  backgroundImage: {
    'brand-gradient':'linear-gradient(180deg,#14365F,#0F2F55)',
    'brand-soft':'linear-gradient(180deg,#FFFFFF,#F8FAFC)',
    trust:'linear-gradient(135deg,#0F3D75,#1F4F87)',
    'hero-fade':'linear-gradient(90deg,rgba(248,249,251,.96) 0,rgba(248,249,251,.88) 35%,rgba(248,249,251,.65) 55%,rgba(248,249,251,.25) 75%,rgba(248,249,251,0) 100%)',
  },
  maxWidth: { container:'1360px' },
}
```
Skala 50–400 & 700–900 hijau di atas adalah turunan (bukan dari situs) agar kelas `primary-50` dst. tetap ada.

## 8. CSS variables (untuk CMS / email / non-Tailwind)
```css
:root{
  --font-heading:"Plus Jakarta Sans",sans-serif; --font-body:"Inter",sans-serif;
  --c-heading:#00214A; --c-primary:#14365F; --c-primary-2:#16355F; --c-primary-deep:#0F2F5F;
  --c-link:#234A74; --c-footer:#1A4978; --c-accent:#198754; --c-accent-hover:#157347;
  --c-up:#1F8A5B; --c-down:#D84B4B; --c-text:#617286; --c-muted:#64748B;
  --c-border:#E5E7EB; --c-border-tint:rgba(15,53,103,.06); --c-input-border:#DBE2EA;
  --bg-page:#F9FAFB; --bg-soft:#F8FAFC; --bg-hero:#F5F7FB;
  --r-btn:18px; --r-input:16px; --r-card:22px; --r-panel:30px;
  --sh-card:0 2px 10px rgba(16,47,85,.025); --sh-hover:0 14px 34px rgba(16,47,85,.06);
}
```

## 9. Flutter (`sekuritas-mobile`)
```dart
const navy900 = Color(0xFF00214A); const navy600 = Color(0xFF14365F);
const green500 = Color(0xFF198754); const textBody = Color(0xFF617286);
const bgSoft = Color(0xFFF8FAFC); const border = Color(0xFFE5E7EB);
// ColorScheme.fromSeed(seedColor: navy600, primary: navy600, secondary: green500)
// Font: google_fonts → PlusJakartaSans (judul) + Inter (body). Radius kartu 22, tombol 18.
```

## 10. Status penerapan
**Sudah diterapkan (2026-09-11) di branch `danapathi`** — klien = PT Danapathi Asset Management, logo Danapathi dipakai:
- `sekuritas-frontend`: tema Tailwind + `assets/css/tailwind.css` (.btn-cta/.btn-primary/.eyebrow/.h-section),
  beranda baru (hero foto, trust strip, produk NAB, alur buka rekening, tentang+FAQ, simulasi, artikel), header/footer, auth & dashboard.
- `sekuritas-cms`: palet navy/hijau, logo putih di sidebar & login.
- `sekuritas-api`: 5 produk Danapathi (NAB sesuai situs; AUM & kinerja = angka demo), event, template email.
- `sekuritas-mobile`: AppColors, logo, ikon launcher, nama app.
- Aset logo: `design/asset+logo/danapathi*.png` (horizontal, horizontal-putih, ikon, lingkaran, bertumpuk) + `danapathi-hero.jpg`.
Branch `main` tetap versi Victoria.
