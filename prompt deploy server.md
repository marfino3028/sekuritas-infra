# PROMPT — Deploy Victoria Sekuritas ke Server

> Tempel prompt ini ke Claude yang punya akses ke server (VPS). Kerjakan berurutan D-1 → D-6. Semua repo publik di GitHub `marfino3028`. Fokus utama: menyalakan **`sekuritas-ai`** (FastAPI eKYC) lalu menyambungkannya ke `sekuritas-api`.

## Konteks
Platform investasi reksa dana "Victoria Sekuritas", 5 komponen:
- `sekuritas-api` — Laravel 12 + PostgreSQL (backend & API, JWT)
- `sekuritas-frontend` — Nuxt 3 (web depan nasabah)
- `sekuritas-cms` — Nuxt 3 (admin)
- `sekuritas-mobile` — Flutter (tidak dideploy ke server; build APK terpisah)
- `sekuritas-ai` — **FastAPI** (eKYC: OCR KTP / liveness / face match) — microservice AI

Target server: VPS Ubuntu dengan Docker + Docker Compose. Domain/subdomain opsional.

---

## D-1 — Siapkan repo `sekuritas-ai` di GitHub (bila belum)
Di mesin lokal (folder `sekuritas-ai`):
```bash
git remote add origin https://github.com/marfino3028/sekuritas-ai.git   # bila belum ada
git push -u origin main
```

## D-2 — Ambil kode di server
```bash
ssh user@SERVER_IP
sudo apt update && sudo apt install -y docker.io docker-compose-plugin git
cd /opt && sudo git clone https://github.com/marfino3028/sekuritas-ai.git
cd sekuritas-ai
cp .env.example .env
# Edit .env:
#   EKYC_AI_API_KEY=<buat-kunci-acak-yang-kuat>   (CATAT — dipakai juga di sekuritas-api)
#   USE_GPU=false   (true bila server ada GPU NVIDIA + nvidia-container-toolkit)
```

## D-3 — Build & jalankan `sekuritas-ai`
```bash
docker build -t victoria-ekyc-ai .
docker run -d --name ekyc-ai --restart unless-stopped \
  -p 127.0.0.1:8000:8000 --env-file .env victoria-ekyc-ai
```
> Catatan: `-p 127.0.0.1:8000:8000` mengikat HANYA ke localhost agar tidak terekspos ke internet.

Uji:
```bash
curl http://127.0.0.1:8000/health                       # -> {"status":"ok",...}
curl -H "X-Api-Key: <EKYC_AI_API_KEY>" -F "file=@ktp.jpg" http://127.0.0.1:8000/ocr
```

## D-4 — (Opsional) Aktifkan model AI nyata
Secara default service memakai stub. Untuk produksi, di dalam `sekuritas-ai`:
1. Uncomment dependency di `requirements.txt` (PaddleOCR, InsightFace, onnxruntime, opencv).
2. Isi bagian `TODO` di `app/services/ocr.py` (PaddleOCR), `face_match.py` (InsightFace ArcFace), `liveness.py` (Silent-Face-Anti-Spoofing).
3. Rebuild image: `docker build -t victoria-ekyc-ai . && docker restart ekyc-ai`.
4. Model berat → pertimbangkan resource (RAM/CPU/GPU) & pre-download model saat build.

## D-5 — Sambungkan `sekuritas-api` → `sekuritas-ai`
Di server yang menjalankan `sekuritas-api`, set `.env`:
```
EKYC_PROVIDER=fastapi
EKYC_FASTAPI_URL=http://127.0.0.1:8000        # atau http://ekyc-ai:8000 bila satu docker network
EKYC_FASTAPI_KEY=<EKYC_AI_API_KEY yang sama dgn D-2>
EKYC_FASTAPI_TIMEOUT=30
```
Lalu:
```bash
php artisan config:cache
```
Uji end-to-end dari web depan: buka `/pembukaan-rekening/ekyc`, lakukan alur KTP→selfie→verifikasi, pastikan skor berasal dari service (cek `docker logs ekyc-ai`).

> **Alternatif (disarankan): satu `docker-compose`.** Ada `docker-compose.yml` di root folder `sekuritas/` yang sudah memuat service `ekyc-ai`, `api`, `postgres`, `redis`, `minio`, `frontend`, `cms`. Bila memakai ini, `EKYC_FASTAPI_URL=http://ekyc-ai:8000` (antar-service by name) dan jalankan `docker compose up -d --build`.

## D-6 — Keamanan (WAJIB)
- **Jangan** ekspos port 8000 ke publik. Biarkan hanya diakses `sekuritas-api` (localhost / docker network / VPN).
- Jika `sekuritas-ai` harus diakses lintas host, taruh di belakang **Nginx** dengan TLS (Let's Encrypt) + allowlist IP + teruskan header `X-Api-Key`, dan `client_max_body_size 10m;`.
- Rotasi `EKYC_AI_API_KEY` bila bocor. Batasi rate limit & ukuran upload.
- Simpan gambar KTP/selfie di storage terenkripsi (S3/MinIO), bukan di disk publik.

Contoh server block Nginx (bila publik via subdomain internal):
```nginx
server {
  server_name ekyc-ai.internal.example.com;
  client_max_body_size 10m;
  location / {
    proxy_pass http://127.0.0.1:8000;
    proxy_set_header X-Api-Key $http_x_api_key;
    proxy_set_header Host $host;
  }
  # listen 443 ssl;  (sertifikat Let's Encrypt)
}
```

## Selesai
Setelah D-5 hijau (skor eKYC dari model), commit perubahan konfigurasi (mis. Nginx conf contoh) ke repo terkait, lalu laporkan status: URL health, provider aktif, dan hasil uji end-to-end.
