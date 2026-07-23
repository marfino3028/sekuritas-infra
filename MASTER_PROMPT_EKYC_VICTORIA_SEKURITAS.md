# MASTER PROMPT — eKYC Victoria Sekuritas

> **Role**
>
> Act as a team consisting of:
> - Senior Solution Architect
> - Fintech Solution Architect
> - Senior Laravel Architect
> - Senior Nuxt Architect
> - Senior Flutter Architect
> - Senior Python AI Engineer
> - Senior DevOps Engineer
> - Senior Security Engineer
> - Senior UI/UX Designer
> - Senior OCR & Computer Vision Engineer
> - Senior Face Recognition Engineer
> - Senior QA Architect

## ✅ STATUS IMPLEMENTASI (per 2026-07-22)

Status tiap bagian `##` di bawah (✅ selesai · ⚠️ sebagian · ⛔ belum):

| Bagian | Status | Keterangan |
|--------|--------|-----------|
| Project Background / Existing Stack / Business Flow | ✅ | 5 repo dibangun; flow eKYC end-to-end jalan (mode stub) |
| Arsitektur (SOLID/Adapter/Strategy/Repository/DI) | ✅ | Adapter dipakai di eKYC, Payment, S-INVEST, Signature |
| UI/UX Research | ✅ | `UIUX_RESEARCH.md` (IA, journey, nav, design system, tipografi, warna, komponen, a11y, states) |
| eKYC Research (OCR/Face/Liveness/Signature) | ✅ | Kurasi repo di `RISET_EKYC_OPEN_SOURCE.md` |
| Untuk setiap repository (atribut) | ⚠️ | Atribut ada di doc; stars/last-commit perkiraan (verifikasi ulang) |
| Integrasi (struktur folder Nuxt/Laravel/Flutter/FastAPI) | ✅ | Semua repo terstruktur; `EkycApi`/`useEkyc` client |
| API (`/ekyc/*`) | ✅ | session/ocr/liveness/face-match/signature/verify/status |
| Database (ekyc_sessions/documents/selfies/signatures/results/logs) | ✅ | Migrasi + model |
| Security | ✅ | JWT, **rate-limit** (auth 10/mnt, eKYC 30/mnt), audit log, **enkripsi file at-rest**, duplicate NIK, flag fraud. (Deteksi printed/replay aktif saat model dinyalakan) |
| Docker | ✅ | Dockerfile tiap repo + `docker-compose.yml` (model masih 1 service `ekyc-ai`) |
| CI/CD | ✅ | GitHub Actions di 5 repo |
| Future Migration (ke ADVANCE.AI/Sumsub/Veriff) | ✅ | **Adapter skeleton Sumsub/Veriff/AdvanceAi** + terdaftar di EkycManager + config vendors |
| Deliverables (SAD/TDD formal) | ✅ | `SAD_TDD.md` (arsitektur C4, model data, kontrak API, sequence, deployment, security) |

**Model AI eKYC** (PaddleOCR/InsightFace/Silent-Face) di `sekuritas-ai`: **kode engine asli SUDAH diimplementasi** (engine-aware + fallback stub). Untuk mengaktifkan: `pip install -r requirements-models.txt`, set `OCR_ENGINE=paddle` / `FACE_MATCH_ENGINE=insightface` / `LIVENESS_ENGINE=silent-face-onnx` + siapkan file model. Default tetap stub.

---

## Project Background

Saya sedang mengembangkan platform **Victoria Sekuritas** untuk pembukaan rekening reksa dana online.

Website existing:
- https://victoria-sekuritas.co.id/

Benchmark:
- https://app.itradefund.cgsi.co.id/

Jangan menyalin desain benchmark. Gunakan hanya sebagai referensi UX, flow, dan best practice.

## Existing Stack

- Website: Nuxt
- Mobile: Flutter
- Backend: Laravel
- Database: PostgreSQL
- Storage: MinIO / S3 Compatible
- Reverse Proxy: Nginx
- Deployment: Docker Compose
- AI Service: Python FastAPI (akan ditambahkan)

Project SUDAH BERJALAN.
Saya ingin MENGINTEGRASIKAN modul eKYC, bukan membuat project baru.

## Business Flow

Registrasi → OTP → Isi Data → Upload KTP → OCR → Selfie →
Passive Liveness → Face Match → Digital Signature →
Review → Submit → Waiting Approval

Target setara:
- ADVANCE.AI
- Sumsub
- Veriff
- Big Vision
- Bos API

Tahap awal WAJIB menggunakan solusi open source & self-hosted.

## Arsitektur

Gunakan:
- SOLID
- Clean Architecture
- Adapter Pattern
- Strategy Pattern
- Repository Pattern
- Service Layer
- DTO
- Dependency Injection

Laravel harus bertindak sebagai API Gateway.

Provider AI harus bisa diganti melalui Adapter tanpa mengubah Nuxt, Flutter maupun business logic Laravel.

## UI/UX Research

Analisis:
- Victoria Sekuritas
- CGS iTrade Fund

Bandingkan:
- Information Architecture
- User Journey
- Navigation
- Design System
- Typography
- Color Palette
- Components
- Accessibility
- Desktop & Mobile UX
- Empty/Error/Loading/Success State

Jika memungkinkan dari asset publik:
- Logo
- Favicon
- Primary/Secondary/Accent Color
- HEX
- RGB
- Typography
- CSS Variables

Jika tidak bisa otomatis, jelaskan cara mendapatkannya melalui DevTools.

## eKYC Research

### OCR KTP

Prioritas:
https://github.com/PaddlePaddle/PaddleOCR

Cari minimal 10 repository GitHub terbaik.

### Face Recognition

Prioritas:
https://github.com/deepinsight/insightface

Cari minimal 10 repository.

### Passive Liveness

Evaluasi:
- OpenKYC
- Face Anti Spoofing
- Silent Liveness
- InsightFace ecosystem

Cari minimal 10 repository GitHub terbaik.

### Signature

Flutter:
https://pub.dev/packages/signature

Web:
https://github.com/szimek/signature_pad

Bandingkan juga alternatif lain.

## Untuk setiap repository

Berikan:
- GitHub URL
- Stars
- Last Commit
- Last Release
- License
- Gratis/Berbayar
- Self Hosted
- Docker Support
- REST API
- Production Ready
- Community
- Accuracy
- CPU/GPU
- Kelebihan
- Kekurangan
- Trade-off

Verifikasi menggunakan:
- Dokumentasi resmi
- GitHub
- Issue Tracker
- Release Notes
- Community

Jika menemukan solusi lebih baik dari yang disebutkan di prompt ini, gunakan solusi tersebut dan jelaskan alasannya.

## Integrasi

Rancang:
- Struktur folder Nuxt
- Struktur folder Laravel
- Struktur folder Flutter
- Struktur folder FastAPI

## API

Rancang endpoint:
- POST /api/ekyc/ocr
- POST /api/ekyc/liveness
- POST /api/ekyc/face-match
- POST /api/ekyc/signature
- POST /api/ekyc/verify
- GET /api/ekyc/status/{id}

Berikan request, response, validation, error handling.

## Database

Rancang PostgreSQL:
- ekyc_sessions
- ekyc_documents
- ekyc_selfies
- ekyc_signatures
- ekyc_results
- ekyc_logs

Lengkap dengan relasi, index, dan alasan desain.

## Security

Bahas:
- JWT
- Refresh Token
- HTTPS
- Rate Limit
- Audit Log
- Image Encryption
- Fraud Detection
- Duplicate Face
- Duplicate KTP
- Screenshot Detection
- Replay Detection
- Printed Photo Detection
- Blur Detection
- Low Light Detection

## Docker

Buat Docker Compose production-ready untuk:
- Nuxt
- Laravel
- PostgreSQL
- MinIO
- Nginx
- FastAPI
- PaddleOCR
- InsightFace
- Liveness Service
- Redis (jika diperlukan)

## CI/CD

Rekomendasikan:
- GitHub Actions
- Build Pipeline
- Test Pipeline
- Deployment Strategy

## Future Migration

Pastikan arsitektur mudah berpindah ke:
- ADVANCE.AI
- Sumsub
- Veriff
- Big Vision
- Bos API

cukup dengan membuat adapter baru.

## Deliverables

Buat jawaban seperti Software Architecture Document (SAD) + Technical Design Document (TDD).

Kerjakan dalam fase:

1. Analisis bisnis & arsitektur
2. Analisis UI/UX & benchmark
3. Riset OCR, Face Match, Liveness, Signature
4. Arsitektur backend & AI
5. Integrasi ke Nuxt/Laravel/Flutter
6. API & Database
7. Docker & DevOps
8. Security & Fraud Prevention
9. Roadmap implementasi

Jika jawaban terlalu panjang, berhenti pada titik yang logis dan tunggu perintah:

**"Lanjutkan"**

Jangan mengulang bagian sebelumnya.
