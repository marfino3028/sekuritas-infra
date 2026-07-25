9I6TFw3MMB4=

## D-1 — Siapkan repo `sekuritas-ai` di GitHub (bila belum)
Di mesin lokal (folder `sekuritas-ai`):
```bash
git remote add origin https://github.com/marfino3028/sekuritas-ai.git   # bila belum ada
git push -u origin main
```
Ingat: push ini TIDAK membawa file model (`*.gguf`, `*.onnx`) — memang sengaja di-gitignore karena ukurannya besar (±3 GB). Model didownload langsung di server pada D-3.

## D-2 — Ambil kode di server & siapkan `.env`
```bash
ssh user@SERVER_IP
sudo apt update && sudo apt install -y docker.io docker-compose-plugin git
cd /opt && sudo git clone https://github.com/marfino3028/sekuritas-ai.git
cd sekuritas-ai
cp .env.example .env
```
Edit `.env`:
- `EKYC_AI_API_KEY=<37e79d08e5bc230a7560d5acb0bdda808db56d85536b6a8c26c5d85320d12485>` (CATAT — dipakai juga di `sekuritas-api` sebagai `EKYC_FASTAPI_KEY`, harus sama persis)
- `USE_GPU=false` (`true` bila server ada GPU NVIDIA + `nvidia-container-toolkit`)
- Biarkan `OCR_ENGINE=nanonets`, `FACE_MATCH_ENGINE=insightface`, `LIVENESS_ENGINE=silent-face-onnx` — ketiganya memang mau diaktifkan langsung di server (bukan stub). Model file-nya disiapkan di D-3.
- `ALLOW_MODEL_DOWNLOADS=true` — supaya model Nanonets otomatis didownload dari Hugging Face saat pertama kali dipakai (lihat D-3).

## D-3 — Siapkan model AI di server (WAJIB sebelum build)

Ada 3 engine, masing-masing butuh model file yang cara siapinnya beda:

**1. Nanonets OCR (GGUF) — auto-download, paling gampang.**
Karena `ALLOW_MODEL_DOWNLOADS=true`, `app/services/nanonets_engine.py` akan otomatis menarik file dari repo Hugging Face `unsloth/Nanonets-OCR-s-GGUF` (env `NANONETS_REPO_ID`) ke `./model/` saat pertama kali dipanggil. Supaya startup container tidak lambat/timeout (karena `NANONETS_PRELOAD_ON_START=true` di `.env.example`), lebih aman download dulu **sebelum** `docker run`:
```bash
mkdir -p model
pip install --user huggingface_hub   # atau pakai python3 -m venv sementara
python3 -c "
from huggingface_hub import hf_hub_download
hf_hub_download(repo_id='unsloth/Nanonets-OCR-s-GGUF', filename='Nanonets-OCR-s-Q4_0.gguf', local_dir='model')
hf_hub_download(repo_id='unsloth/Nanonets-OCR-s-GGUF', filename='mmproj-F16.gguf', local_dir='model')
"
```
Total unduhan ±2.95 GB — pastikan disk & bandwidth VPS cukup, dan file hasil download namanya cocok dengan `NANONETS_MODEL_FILE` / `NANONETS_MMPROJ_FILE` di `.env` (`Nanonets-OCR-s-Q4_0.gguf`, `mmproj-F16.gguf`).

**2. InsightFace (face match) — auto-download oleh library itu sendiri.**
Tidak perlu langkah manual: saat `FACE_MATCH_ENGINE=insightface` dipakai pertama kali, library `insightface` otomatis mendownload model `buffalo_l` ke `~/.insightface` di dalam container. Syaratnya container harus punya akses internet keluar saat runtime (bukan cuma saat build).

**3. Liveness (ONNX) — pakai model Facenox, auto-download via script.**
`LIVENESS_ENGINE=facenox-onnx` (default di `.env.example`) memakai model [facenox/face-antispoof-onnx](https://github.com/facenox/face-antispoof-onnx) (MiniFASNetV2-SE, quantized ~600KB, akurasi ~98% di CelebA Spoof). Beda dari Silent-Face lama, model ini kecil dan ada file siap-pakai di repo-nya, jadi tinggal download pakai script:
```bash
chmod +x scripts/download_liveness_model.sh
./scripts/download_liveness_model.sh
# hasil: model/liveness/best_model_quantized.onnx (~600KB)
```
Engine ini otomatis pakai detector wajah dari InsightFace (yang memang sudah aktif buat face-match) untuk crop wajah dulu sebelum inference — jadi tidak perlu download model detector terpisah, asal `FACE_MATCH_ENGINE=insightface` tetap aktif.

> Kalau suatu saat mau pindah ke model Silent-Face-Anti-Spoofing yang asli (3 kelas: live/print/replay) alih-alih Facenox, set `LIVENESS_ENGINE=silent-face-onnx` dan taruh file `.onnx`-nya di `LIVENESS_MODEL_DIR` (default `./model/liveness`) — dua engine ini bisa hidup berdampingan di codebase yang sama, tinggal ganti env.

## D-4 — Build & jalankan `sekuritas-ai`

Dockerfile bawaan repo ini **hanya** install `requirements.txt` (dependency ringan/stub: fastapi, uvicorn). Supaya engine asli (Nanonets/InsightFace/Facenox) benar-benar jalan, dependency berat di `requirements-models.txt` (`llama-cpp-python`, `insightface`, `onnxruntime`, `pytesseract`, dll) juga harus ikut ter-install di image. `llama-cpp-python` di-compile dari source, jadi butuh build tools.

Cek dulu di server apakah build tools (`build-essential`, `cmake`, `git`) tersedia/mudah dipasang langsung di server (di luar Docker). Kalau ribet/tidak memungkinkan, satukan saja ke dalam Dockerfile (disarankan — image jadi portable, tidak tergantung environment server):

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Dependency sistem: OpenCV/InsightFace/ONNX runtime + build tools utk compile llama-cpp-python
RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 libgl1 build-essential cmake git \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt requirements-models.txt ./
RUN pip install --no-cache-dir -r requirements.txt -r requirements-models.txt

COPY . .

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build & jalankan:
```bash
docker build -t victoria-ekyc-ai .
docker run -d --name ekyc-ai --restart unless-stopped \
  -p 127.0.0.1:8000:8000 --env-file .env -v $(pwd)/model:/app/model \
  victoria-ekyc-ai
```
> Catatan:
> - `-p 127.0.0.1:8000:8000` mengikat HANYA ke localhost agar tidak terekspos ke internet.
> - `-v $(pwd)/model:/app/model` supaya model besar (±3 GB) tidak ikut ter-copy ke dalam image saat build (image jadi lebih ringan) dan bisa diganti/diupdate tanpa rebuild.
> - Karena `NANONETS_PRELOAD_ON_START=true`, model di-load saat container start — proses `docker run` pertama bisa terasa lama (model ±3 GB dibaca ke RAM). Pastikan VPS punya RAM cukup (minimal ~4 GB longgar di luar kebutuhan service lain).

Uji:
```bash
curl http://127.0.0.1:8000/health                       # -> {"status":"ok",...}
curl -H "X-Api-Key: <EKYC_AI_API_KEY>" -F "file=@ktp.jpg" http://127.0.0.1:8000/ocr
```
Cek juga `docker logs ekyc-ai` — pastikan tidak ada error `EngineUnavailableError`/`ImportError` terkait `llama_cpp`, `insightface`, atau `onnxruntime` (tanda dependency belum lengkap), dan pastikan field `"engine"` di response bukan `"stub"` kalau memang mau pakai model asli.

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

> **Alternatif (disarankan): satu `docker-compose`.** Ada `docker-compose.yml` di root folder `sekuritas/` yang sudah memuat service `ekyc-ai`, `api`, `postgres`, `redis`, `minio`, `frontend`, `cms`. Bila memakai ini, `EKYC_FASTAPI_URL=http://ekyc-ai:8000` (antar-service by name) dan jalankan `docker compose up -d --build`. Tambahkan juga volume mount model (`./sekuritas-ai/model:/app/model`) dan step download model (D-3) sebelum `docker compose up` pertama kali.

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
Setelah D-5 hijau (skor eKYC dari model asli — cek field `"engine"` di response bukan `"stub"` untuk ketiganya: OCR, face match, liveness), commit perubahan konfigurasi (mis. Dockerfile yang sudah include `requirements-models.txt` + build tools, dan Nginx conf contoh) ke repo terkait, lalu laporkan status: URL health, engine aktif per fitur (OCR/face match/liveness), dan hasil uji end-to-end.

## D-6b — Setup MySQL & Redis via Docker (server baru, belum ada DB)

Karena server baru ini awalnya cuma disiapkan buat AI, MySQL & Redis belum ada. Jalankan sebagai container, satu Docker network bareng service lain biar bisa saling connect by name:

```bash
docker network create sekuritas-net

docker run -d --name sekuritas-mysql --restart unless-stopped \
  --network sekuritas-net \
  -e MYSQL_ROOT_PASSWORD=changeme_root \
  -e MYSQL_DATABASE=sekuritas_demo \
  -v sekuritas-mysql-data:/var/lib/mysql \
  -p 127.0.0.1:3306:3306 \
  mysql:8.0

docker run -d --name sekuritas-redis --restart unless-stopped \
  --network sekuritas-net \
  -p 127.0.0.1:6379:6379 \
  redis:7

# sambungkan ekyc-ai (yang dijalankan manual, bukan compose) ke network yang sama
docker network connect sekuritas-net ekyc-ai
```

Update `.env` `sekuritas-api`:
```bash
cd /opt/victoria-sekuritas/sekuritas-api
sed -i "s|^DB_HOST=.*|DB_HOST=sekuritas-mysql|" .env
sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=changeme_root|" .env
sed -i "s|^REDIS_HOST=.*|REDIS_HOST=sekuritas-redis|" .env
```
> `DB_PASSWORD` di `.env` harus sama persis dengan `MYSQL_ROOT_PASSWORD` di atas.

Cek MySQL sudah siap (tunggu log `ready for connections`):
```bash
docker logs sekuritas-mysql --tail 20
```

## D-6c — Build & jalankan `sekuritas-api` (Docker)

`sekuritas-api` juga dijalankan via Docker (bukan native PHP di host).

> **PENTING — port container BUKAN 8000, tapi 80.** Cek `Dockerfile` (`EXPOSE 80`) dan `docker-entrypoint.sh`: Nginx di dalam container dengar di port 80 (di-override lewat env `$PORT` kalau di-set, kalau tidak default tetap 80). Jadi mapping port host wajib `host:80`, BUKAN `host:8000`.
>
> **Port host juga TIDAK BOLEH 8000** di server ini — port itu sudah dipakai proses lain milik user lain (`python3`, user `candrapwr`), di luar kendali kita. Pakai port host **8002** (8000 dipakai proses lain, 8001 dipakai `ekyc-ai`). Kalau nanti mau redeploy, cek dulu `sudo lsof -i :<port>` sebelum pakai port host tertentu.
>
> **`docker exec ... php artisan key:generate/config:cache/migrate` TIDAK PERLU dijalankan manual** — semua sudah otomatis dijalankan oleh `docker-entrypoint.sh` setiap kali container start (generate `APP_KEY` & `JWT_SECRET` kalau belum ada, migrate dengan retry loop ~30 detik, seed kalau tabel `users`/`mutual_funds` masih kosong, lalu `config:cache`/`route:cache`/`view:cache`). Cukup jalankan container dan pantau lewat `docker logs`.

```bash
cd /opt/victoria-sekuritas/sekuritas-api
docker build -t sekuritas-api .

# kalau ada sisa container gagal dari percobaan sebelumnya, hapus dulu:
# docker rm <container_id>

docker run -d --name sekuritas-api --restart unless-stopped \
  --network sekuritas-net \
  -p 127.0.0.1:8002:80 \
  --env-file .env \
  sekuritas-api

# pantau startup (migrate/seed otomatis jalan di sini)
docker logs -f sekuritas-api
```

Test dari host:
```bash
curl http://127.0.0.1:8002/api/health
```
> ✅ Terverifikasi jalan: `{"status":"ok","service":"Sekuritas Demo API",...}`

**Kredensial demo hasil auto-seed** (dari `docker-entrypoint.sh`, jangan dipakai di production, ganti password setelah go-live):
- Login CMS: `admin@sekuritas-demo.id` / `Admin@123456`
- Login Ops: `ops@sekuritas-demo.id` / `Ops@123456`
- Nasabah demo (10 akun): password `Nasabah@123`
- Data ter-seed otomatis: 10 produk reksa dana, 4 event demo, 12 artikel, 19 pendaftaran event.

Karena `sekuritas-api` sekarang satu network (`sekuritas-net`) dengan `ekyc-ai`, `EKYC_FASTAPI_URL` bisa pakai nama container **dengan port internal `ekyc-ai` yaitu 8000** (bukan 8001 — 8001 itu port host punya `ekyc-ai`, bukan port di dalam container-nya):
```bash
sed -i "s|^EKYC_FASTAPI_URL=.*|EKYC_FASTAPI_URL=http://ekyc-ai:8000|" .env
```

## D-7 — Deploy `sekuritas-cms` (Nuxt, sudah ada Dockerfile)

```bash
cd /opt/victoria-sekuritas
sudo git clone https://github.com/marfino3028/sekuritas-cms.git
cd sekuritas-cms
cp .env.example .env
```
Edit `.env` — variable yang BENAR-benar dipakai (dikonfirmasi dari `.env.example` asli repo, bukan tebakan) adalah `NUXT_PUBLIC_API_BASE`, bukan `NUXT_PUBLIC_API_URL`, dan formatnya sudah termasuk path `/api/cms`:
```
NUXT_PUBLIC_API_BASE=http://sekuritas-api/api/cms
```
> Port container `sekuritas-api` adalah **80** (default, tidak perlu ditulis eksplisit — `http://sekuritas-api` sudah otomatis ke port 80). Port host (8002) tidak relevan di sini karena ini komunikasi antar-container lewat Docker network, bukan lewat host.
Build & jalankan (gabung ke `sekuritas-net`):
```bash
docker build -t sekuritas-cms .
docker run -d --name sekuritas-cms --restart unless-stopped \
  --network sekuritas-net \
  -p 127.0.0.1:3001:3000 \
  --env-file .env \
  sekuritas-cms
```
Uji: `curl -I http://127.0.0.1:3001`

## D-8 — Deploy `sekuritas-frontend` (Nuxt, sudah ada Dockerfile)

```bash
cd /opt/victoria-sekuritas
sudo git clone https://github.com/marfino3028/sekuritas-frontend.git
cd sekuritas-frontend
cp .env.example .env
```
Edit `.env` — sama seperti `sekuritas-cms`, variable-nya `NUXT_PUBLIC_API_BASE` (bukan `NUXT_PUBLIC_API_URL`), path `/api` (tanpa `/cms`):
```
NUXT_PUBLIC_API_BASE=http://sekuritas-api/api
```
Build & jalankan:
```bash
docker build -t sekuritas-frontend .
docker run -d --name sekuritas-frontend --restart unless-stopped \
  --network sekuritas-net \
  -p 127.0.0.1:3000:3000 \
  --env-file .env \
  sekuritas-frontend
```
Uji: `curl -I http://127.0.0.1:3000`

## D-9 — Reverse proxy publik (Nginx) untuk api/cms/frontend

Jangan expose `ekyc-ai` ke publik (tetap `127.0.0.1` saja). Untuk `api`, `cms`, `frontend`:
```nginx
server {
  server_name app.domainkamu.com;
  location / { proxy_pass http://127.0.0.1:3000; proxy_set_header Host $host; }
}
server {
  server_name cms.domainkamu.com;
  location / { proxy_pass http://127.0.0.1:3001; proxy_set_header Host $host; }
}
server {
  server_name api.domainkamu.com;
  location / { proxy_pass http://127.0.0.1:8000; proxy_set_header Host $host; }
  client_max_body_size 10m;
}
```
Pasang TLS (Let's Encrypt/certbot) per subdomain, lalu update `.env` masing-masing app (`APP_URL`, `NUXT_PUBLIC_API_URL`, `FRONTEND_URL`, `CMS_URL`) ke domain HTTPS.

> ⚠️ Port & nama env var di D-7/D-8 masih asumsi pola project sebelumnya — cross-check dengan isi `Dockerfile` dan `.env.example` asli tiap repo sebelum eksekusi.
