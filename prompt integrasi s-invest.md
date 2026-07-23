# PROMPT — Integrasi S-INVEST (KSEI) + RDN Asli — Victoria Sekuritas

> Tempel prompt ini ke Claude **hanya setelah kredensial KSEI & bank RDN dari klien tersedia**. Sebelum itu, sistem tetap memakai mode simulasi (`SInvestService` mock) untuk demo/UAT.

## Konteks
Project `sekuritas-api` (Laravel) sudah punya:
- Tabel `sid_data` (menyimpan SID/IFUA + raw response), kolom `users.sid_status/sid_number/ifua_number`.
- `App\Services\SInvestService` (saat ini **mock** — generate SID/IFUA palsu).
- Flow 2 langkah di CMS: **Approve KYC** lalu **Kirim ke S-INVEST** (`POST /api/cms/kyc/{id}/issue-sid` → `SInvestService::generateSid($userId)`).

Tugas: ganti mock jadi **integrasi S-INVEST (KSEI) asli** + pembukaan **RDN** di bank administrator, tanpa mengubah controller/CMS/mobile (cukup ubah layer service + config).

## ⚠️ Prasyarat dari KLIEN (Victoria) — minta & pastikan ada sebelum mulai
Kirim checklist ini ke klien; integrasi tidak bisa jalan tanpa semuanya:
1. **Izin OJK** aktif (Perusahaan Efek / APERD) — konfirmasi status.
2. **Keanggotaan/Partisipan KSEI** + **kredensial S-INVEST**: participant code, user/secret, sertifikat, dan detail **kanal koneksi** (host-to-host / SFTP / API / VPN / IP allowlist).
3. **Spesifikasi teknis S-INVEST** resmi dari KSEI: format request/response registrasi investor (SID), pembuatan **IFUA**, field wajib, kode error, dan environment **UAT** + **production**.
4. **Bank Administrator RDN** partner (mis. BCA/CIMB Niaga/BRI/Permata): API/prosedur pembukaan RDN, mapping field, dan kredensial.
5. Kebijakan data: retensi, enkripsi, dan siapa PIC compliance untuk UAT KSEI.

> Jika salah satu belum ada → STOP, laporkan ke klien. Jangan hardcode kredensial.

## Arsitektur (pertahankan adapter pattern)
Ubah `SInvestService` menjadi berbasis driver, mirip modul eKYC:
```
App\Services\SInvest\Contracts\SInvestProvider   (interface: registerInvestor(), checkStatus())
App\Services\SInvest\Providers\MockProvider      (yang sekarang — untuk dev/UAT internal)
App\Services\SInvest\Providers\KseiProvider      (BARU — koneksi S-INVEST asli)
App\Services\SInvest\SInvestManager              (pilih driver via config)
config/sinvest.php                               (SINVEST_DRIVER=mock|ksei, kredensial, base_url, cert path, participant_code, timeout)
```
`SInvestService::generateSid()` memanggil provider terpilih; simpan `s_invest_response` mentah ke `sid_data` untuk audit.

## Langkah kerja
1. **Refactor** `SInvestService` ke pola manager+provider di atas (jaga signature `generateSid(int $userId): array` & `checkSidStatus()` agar controller tak berubah). Pindahkan logika mock ke `MockProvider`.
2. **`config/sinvest.php` + `.env`**:
   ```
   SINVEST_DRIVER=ksei
   SINVEST_BASE_URL=...          # dari KSEI (UAT dulu)
   SINVEST_PARTICIPANT_CODE=...
   SINVEST_USER=...
   SINVEST_SECRET=...
   SINVEST_CERT_PATH=...         # bila pakai mutual TLS
   SINVEST_TIMEOUT=60
   RDN_BANK=cimb                 # bank administrator RDN
   RDN_BASE_URL=... RDN_KEY=...
   ```
   Simpan secret via env/secret manager, JANGAN commit.
3. **`KseiProvider`**: implementasi `registerInvestor($user, $kyc)`:
   - Susun payload sesuai spesifikasi KSEI (data KTP, NPWP bila ada, alamat, dsb dari tabel `kyc`).
   - Kirim ke S-INVEST (Http client + TLS/cert), tangani retry idempoten, timeout, dan mapping **kode error KSEI** → pesan Indonesia.
   - Parse SID + IFUA dari response; kembalikan array `{ sid_number, ifua_number, s_invest_response }`.
4. **RDN**: buat `RdnService`/provider untuk buka Rekening Dana Nasabah di bank partner (bila alurnya terpisah dari S-INVEST). Simpan nomor RDN di user/kyc (tambah kolom bila perlu via migrasi).
5. **Idempotency & status**: sebelum kirim, cek `users.sid_status` (`not_generated/processing/active`) agar tidak dobel. Set `processing` saat mulai, `active` saat sukses, kembalikan error jelas saat gagal (tanpa mengunci selamanya).
6. **Audit & keamanan**: log tiap panggilan (tanpa menaruh secret di log), enkripsi data sensitif, patuhi allowlist IP KSEI.
7. **Webhook/callback** (bila KSEI async): sediakan endpoint aman untuk update status SID.

## Uji
- **UAT KSEI dulu** (environment test) sampai lulus conformance test KSEI, baru production.
- Uji dari CMS: nasabah dummy → Approve KYC → **Kirim ke S-INVEST** → pastikan SID/IFUA asli tersimpan di `sid_data` + `users`.
- Tambah feature test yang memakai `SINVEST_DRIVER=mock` (agar CI tidak memanggil KSEI asli), plus tes unit untuk mapping payload/response `KseiProvider`.
- Uji skenario gagal: kredensial salah, timeout, investor sudah punya SID, error validasi KSEI.

## Deliverable
- `SInvestService` berbasis driver + `KseiProvider` + `config/sinvest.php` + `.env.example` (tanpa secret).
- (Opsional) `RdnService` untuk pembukaan RDN.
- Dokumen singkat: cara set env, cara switch mock↔ksei, dan hasil UAT KSEI.
- Commit & push; JANGAN aktifkan `SINVEST_DRIVER=ksei` di production sebelum UAT lulus & disetujui compliance klien.
