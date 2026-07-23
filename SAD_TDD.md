# SAD + TDD — Platform Victoria Sekuritas (fokus eKYC)

**Software Architecture Document (SAD) + Technical Design Document (TDD).**
Dokumen ini menjawab bagian *Deliverables* di `MASTER_PROMPT_EKYC_VICTORIA_SEKURITAS.md`.

---

## 1. Ringkasan & Tujuan
Platform investasi reksa dana yang mengadopsi flow CGS iTradeFund dengan brand Victoria (merah `#A40001`). Mendukung: registrasi, **eKYC** (OCR KTP, liveness, face match, tanda tangan), profil risiko, katalog & transaksi reksa dana, promo/event referral, dan back-office (CMS). Backend menjadi **API Gateway**; integrasi AI & pihak ketiga memakai **Adapter Pattern** agar dapat di-swap tanpa mengubah business logic.

## 2. Konteks Sistem (C4 — Level 1)
```
[Nasabah] --web--> (sekuritas-frontend, Nuxt)  ─┐
[Nasabah] --app--> (sekuritas-mobile, Flutter) ─┼─HTTP/JSON─> (sekuritas-api, Laravel) ──> [PostgreSQL]
[Admin]   --web--> (sekuritas-cms, Nuxt)       ─┘                    │  │  │
                                                                     │  │  └─> (S3/MinIO) file KTP/selfie/ttd (opsional terenkripsi)
                                                                     │  └────> (sekuritas-ai, FastAPI) OCR/liveness/face-match
                                                                     └───────> Pihak ketiga: Midtrans, KSEI/S-INVEST, Privy, SMTP
```

## 3. Komponen (C4 — Level 2)
| Komponen | Teknologi | Tanggung jawab |
|----------|-----------|----------------|
| `sekuritas-frontend` | Nuxt 3, Pinia, Tailwind | Portal nasabah: katalog, eKYC, transaksi, promo |
| `sekuritas-cms` | Nuxt 3, Pinia, Tailwind | Back-office: KYC review, SID, produk/NAV, event, laporan |
| `sekuritas-api` | Laravel 12, PostgreSQL, JWT | API Gateway + business logic + adapter integrasi |
| `sekuritas-ai` | FastAPI (Python) | Inferensi OCR/liveness/face-match (PaddleOCR/InsightFace/Silent-Face) |
| `sekuritas-mobile` | Flutter, Riverpod, Dio | App nasabah (mirror flow web) |

## 4. Prinsip & Pola Arsitektur
- **Clean-ish layering** di Laravel: Controller → Service (orchestrator) → Provider (adapter) → Model/Storage.
- **Adapter Pattern** untuk semua integrasi yang dapat berubah:
  - eKYC: `EkycProvider` ⟵ `StubProvider` | `FastApiProvider` | `Sumsub/Veriff/AdvanceAi`
  - Payment: `PaymentGateway` ⟵ `MockGateway` | `MidtransGateway`
  - SID: `SInvestProvider` ⟵ `MockProvider` | `KseiProvider`
  - Signature: canvas | Privy
  - Semua dipilih via `config()` + env → **swap tanpa ubah controller**.
- **DTO** menstabilkan kontrak lintas provider (`OcrResult`, `LivenessResult`, `FaceMatchResult`).
- **DI** via Laravel container (Manager di-`singleton`).
- **Stateless** API (JWT), file di object storage.

## 5. Model Data (inti)
- **users** (sid_status, sid_number, ifua_number, activation_token, role, status)
- **kyc** (nik, data pribadi/pekerjaan/finansial, ktp/selfie path, status, reviewed_by)
- **eKYC**: `ekyc_sessions` (uuid, status, provider, score, auto_approved) → `ekyc_documents` (OCR + flag kualitas), `ekyc_selfies` (liveness+facematch+embedding), `ekyc_signatures`, `ekyc_results` (skor & decision), `ekyc_logs` (audit append-only)
- **sid_data** (sid_number, ifua_number, s_invest_response)
- **mutual_funds / nav_histories / aum_histories**, **transactions / payments / portfolios**
- **events / event_registrations** (kode referral + leaderboard), **articles**, **risk_profiles**

## 6. Kontrak API eKYC (TDD)
Semua di grup `auth:api` + `throttle:30,1`.
| Endpoint | Body | Response (data) |
|----------|------|-----------------|
| `POST /api/ekyc/session` | — | `{id,status,provider,...}` |
| `POST /api/ekyc/ocr` | multipart `file`(+session_id, override nik/nama) | `{session, ocr, ktp_url}` |
| `POST /api/ekyc/liveness` | multipart `file`, session_id | `{session, liveness}` |
| `POST /api/ekyc/face-match` | session_id | `{session, face_match}` |
| `POST /api/ekyc/signature` | session_id, signature(dataURI) | `{session, signature}` |
| `POST /api/ekyc/verify` | session_id | `{session, result{ocr_score,liveness_score,face_match_score,final_score,decision,flags}}` |
| `GET  /api/ekyc/status/{id}` | — | sesi + relasi lengkap |

**AI service** (`sekuritas-ai`, header `X-Api-Key`): `POST /ocr|/liveness|/face-match`, `GET /health`.

### Skoring & keputusan (verify)
`final = 0.2·OCR + 0.35·Liveness + 0.45·FaceMatch`. `decision`: ada fraud-flag → `rejected`; `final ≥ auto_approve(85)` → `approved`; `final < min_reject(50)` → `rejected`; selain itu → `review`. Lolos → identitas OCR disalin ke tabel `kyc` (status pending) untuk review admin.

## 7. Sequence — eKYC end-to-end
```
Nasabah → Frontend: pilih KTP → (OCR on-device Tesseract) 
Frontend → API /ekyc/session → /ekyc/ocr(file+override)
API → EkycService → EkycManager.provider().ocr() → (stub | FastAPI PaddleOCR)
Frontend → /ekyc/liveness → /ekyc/face-match  (provider liveness + faceMatch)
Frontend → /ekyc/signature (canvas/Privy) → /ekyc/verify
API → hitung skor → EkycResult → sync ke kyc(pending) → kirim CompleteAccountMail
--- (back-office) ---
Ops(CMS) → /cms/kyc/{id} (lihat skor) → approve → /cms/kyc/{id}/issue-sid
API → SInvestService → SInvestManager.provider().registerInvestor() → SID/IFUA
```

## 8. Deployment
- Docker per repo + `docker-compose.yml` (postgres, redis, minio, api, ekyc-ai, frontend, cms).
- `ekyc-ai` di jaringan internal (port tidak publik); diakses hanya oleh `api`.
- Env memilih driver: `EKYC_PROVIDER`, `PAYMENT_GATEWAY`, `SINVEST_DRIVER`, `OCR/FACE/LIVENESS_ENGINE`.
- CI/CD: GitHub Actions (build/test) tiap repo. Deploy: `prompt deploy server.md`.

## 9. Non-fungsional & Keamanan
- **Auth**: JWT (tymon), `throttle` di auth (10/mnt) & eKYC (30/mnt).
- **Data KTP/selfie**: object storage; **enkripsi at-rest** opsional (`EKYC_ENCRYPT_FILES`, AES-256 via `EkycFileStore`); sajikan lewat endpoint terproteksi di produksi.
- **Anti-fraud**: flag blur/low-light/screenshot/printed/replay/liveness-failed + **duplicate NIK**; deteksi asli aktif saat model AI dinyalakan. Embedding wajah (InsightFace) untuk cek duplikat wajah.
- **Audit**: `ekyc_logs` append-only (step, provider, latency, status, ip).
- **Kepatuhan**: eKYC/SID/tanda tangan resmi tunduk OJK & KSEI; aktivasi setelah izin/kredensial klien.

## 10. Roadmap sisa
1. Aktifkan model AI (`OCR_ENGINE=paddle`, dst + `requirements-models.txt`).
2. Integrasi produksi: Midtrans, KSEI/S-INVEST+RDN, Privy (kredensial klien).
3. Implement body adapter vendor (Sumsub/Veriff/ADVANCE.AI) bila dipilih.
4. QA end-to-end lintas platform + build rilis mobile.
