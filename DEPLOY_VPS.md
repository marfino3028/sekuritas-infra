# Deploy Victoria Sekuritas ke VPS Baru (untuk demo)

Panduan ini **menggantikan** `prompt deploy server.md` (yang lama ditulis untuk server
bersama yang sudah habis, banyak port/nama env yang tidak cocok lagi). Semua service
jalan lewat **satu `docker-compose.yml`** di folder ini.

```
Internet ──HTTPS──► Nginx (VPS) ─┬─► app.domain  → frontend  (127.0.0.1:3000)
                                 ├─► cms.domain  → cms       (127.0.0.1:3001)
                                 └─► api.domain  → api       (127.0.0.1:8080) ──► ekyc-ai (internal :8000)
                                                               └──► postgres (internal)
```

---

## 1. Beli server — spesifikasi

| Mode | Kapan dipakai | Minimal | Disarankan |
|---|---|---|---|
| **A. AI asli** (OCR KTP auto-isi form, liveness & face match beneran) | Demo ke klien — eKYC adalah fitur utama | 4 vCPU · 8 GB RAM · 40 GB SSD | 4–6 vCPU · 8–12 GB RAM · 60 GB SSD |
| **B. Stub** (tanpa AI; skor eKYC simulasi, form KTP diisi manual) | Hemat / sekadar tunjukkan alur | 2 vCPU · 4 GB RAM · 25 GB SSD | — |

- OS: **Ubuntu 22.04 / 24.04 LTS**, arsitektur x86_64.
- Alasan 8 GB untuk mode A: model Nanonets-OCR (GGUF 1.8 GB + mmproj 1.3 GB) di-load ke RAM,
  ditambah InsightFace, Postgres, PHP, dan proses build Nuxt.
- Kandidat penyedia: Contabo / Hetzner (murah, RAM besar), atau lokal IDCloudHost / Biznet Gio
  (latensi Indonesia lebih baik). Cek harga terbaru di situs masing-masing.
- Server sebaiknya **khusus untuk project ini** (server lama dipakai bersama sehingga port 8000 bentrok).

## 2. Domain & DNS
Buat 3 record **A** yang mengarah ke IP VPS, misalnya:
```
app.domainkamu.com   → IP_VPS     (web nasabah)
cms.domainkamu.com   → IP_VPS     (admin)
api.domainkamu.com   → IP_VPS     (backend)
```
> **HTTPS wajib**: browser hanya mengizinkan kamera (foto KTP/selfie) di halaman HTTPS.
> Tanpa domain, eKYC hanya bisa lewat tombol **Upload File**.

## 3. Siapkan VPS (sekali)
```bash
ssh root@IP_VPS
apt update && apt -y upgrade
apt -y install git nginx certbot python3-certbot-nginx curl ufw
curl -fsSL https://get.docker.com | sh

# Swap 4 GB — mencegah build Nuxt / load model kehabisan RAM
fallocate -l 4G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Firewall: SSH + HTTP/HTTPS. PENTING: kalau SSH bukan port 22 (mis. 717), buka port itu DULU
# sebelum enable — `ufw allow OpenSSH` hanya membuka 22 dan bisa mengunci Anda dari server.
SSH_PORT=$(ss -tlnp | awk '/sshd/ {split($4,a,":"); print a[length(a)]; exit}')
ufw allow ${SSH_PORT:-22}/tcp && ufw allow 'Nginx Full' && ufw --force enable
```

## 4. Clone semua repo (sejajar)
```bash
mkdir -p /opt/victoria && cd /opt/victoria
for r in sekuritas-infra sekuritas-api sekuritas-ai sekuritas-frontend sekuritas-cms; do
  GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/marfino3028/$r.git
done
```
`GIT_LFS_SKIP_SMUDGE=1` = aset desain (gif/png besar di `sekuritas-infra/design`) tidak ikut diunduh — server tidak butuh.

**Versi Danapathi** (tampilan & data Danapathi Asset Management) ada di branch `danapathi` untuk
`sekuritas-api`, `sekuritas-frontend`, `sekuritas-cms` (dan `sekuritas-mobile`). `sekuritas-ai` & `sekuritas-infra` tetap `main`:
```bash
cd /opt/victoria
for r in sekuritas-api sekuritas-frontend sekuritas-cms; do git -C $r checkout danapathi; done
```
Lalu di `.env` (langkah 6) set `APP_NAME="Danapathi API"` dan `MAIL_FROM_NAME="Danapathi Asset Management"`.

## 5. Unduh model AI (mode A saja, ±3 GB)
```bash
bash /opt/victoria/sekuritas-ai/scripts/download_models.sh
```
Hasil di `sekuritas-ai/model/` (nama file sudah cocok dengan config). InsightFace `buffalo_l`
terunduh otomatis saat pertama dipakai ke `model/insightface/`.

## 6. Isi `.env`
```bash
cd /opt/victoria/sekuritas-infra
cp .env.example .env
echo "APP_KEY=base64:$(openssl rand -base64 32)"
echo "JWT_SECRET=$(openssl rand -hex 32)"
echo "EKYC_AI_API_KEY=$(openssl rand -hex 32)"
nano .env
```
Tempel 3 nilai di atas, lalu isi:
- `PUBLIC_API_ORIGIN`, `PUBLIC_FRONTEND_URL`, `PUBLIC_CMS_URL` → domain HTTPS dari langkah 2.
- `DB_PASSWORD` → password bebas.
- **Email aktivasi**: untuk demo ke klien isi SMTP (`MAIL_MAILER=smtp` + host/user/pass). Kalau
  tetap `log`, link aktivasi diambil manual (lihat langkah 9).
- **Mode B (stub)**: set `EKYC_WITH_MODELS=false`, `OCR_ENGINE=stub`, `FACE_MATCH_ENGINE=stub`,
  `LIVENESS_ENGINE=stub`, `SELFIE_KTP_ENGINE=stub`, `NANONETS_PRELOAD_ON_START=false`.

> Jangan ubah `APP_KEY` / `JWT_SECRET` setelah jalan — semua sesi login jadi tidak valid.

## 6b. Server kecil / sudah dipakai aplikasi lain
Perkiraan RAM yang dipakai stack ini **saat berjalan**:

| Komponen | Mode B (stub) | Mode A (AI asli) |
|---|---|---|
| postgres + api (nginx+php-fpm) | ±300–450 MB | ±300–450 MB |
| frontend (nginx) + cms (serve) | ±80 MB | ±80 MB |
| ekyc-ai | ±80 MB | ±3,5–4,5 GB (Nanonets 3 GB + InsightFace) |
| **Total** | **±0,5–0,7 GB** | **±4–5 GB** |

Saat **build** pertama, `nuxt generate` butuh ±1,5–2 GB per aplikasi dan compose membangun paralel.
Di server dengan RAM bebas < 3 GB, build satu per satu agar tidak kehabisan RAM/swap:
```bash
COMPOSE_PARALLEL_LIMIT=1 docker compose build
docker compose up -d
```
Cek sisa RAM dulu: `free -h` (lihat kolom *available*) dan `nproc`. Mode A butuh *available* ≥ 5 GB.

### Mode A hemat RAM (server dengan *available* ±4 GB)
Model OCR varian lebih kecil + konteks lebih pendek + model wajah kecil → turun ±0,8 GB (±3,3 GB total AI):
```bash
# .env
NANONETS_MODEL_FILE=Nanonets-OCR-s-Q3_K_M.gguf     # 1,6 GB (Q4_0 = 1,8 GB); mmproj tetap 1,3 GB
NANONETS_CTX_SIZE=4096                              # KV-cache ±150 MB (8192 = ±300 MB)
INSIGHTFACE_MODEL_NAME=buffalo_s                    # ±160 MB (buffalo_l = ±330 MB)
NANONETS_N_THREADS=<jumlah vCPU>
# unduh varian yang sama:
NANONETS_MODEL_FILE=Nanonets-OCR-s-Q3_K_M.gguf bash ../sekuritas-ai/scripts/download_models.sh
```
Konsekuensi: akurasi baca KTP sedikit turun (cek hasil dengan `design/ktp.jpeg`), dan di CPU 2–4 vCPU
satu foto KTP butuh ±30–90 detik. Kalau RAM kurang, container `ekyc-ai` akan `Killed`/restart
(`docker compose logs ekyc-ai`) → pakai §6c atau tambah RAM.

## 6c. Mode A "hybrid": AI dijalankan di laptop saat demo
Server tetap ringan; OCR/liveness/face-match ASLI dikerjakan laptop (Mac M1 → GPU Metal, cepat) yang dibuka
ke internet lewat **Cloudflare Tunnel** dengan hostname tetap (mis. `https://ai.hamztech.my.id`, gratis,
URL tidak berubah). Syarat: DNS domain di Cloudflare, laptop menyala & online selama demo, RAM laptop
bebas ±4 GB (matikan Docker/colima & aplikasi berat).

```
Browser ─► demo./cms./api.<domain> (VPS) ──► api ──HTTPS + X-Api-Key──► ai.<domain> (Cloudflare) ──tunnel──► laptop :8001
```

**Di laptop** (repo `sekuritas-ai`):
```bash
bash scripts/laptop-ai.sh setup   # sekali: dependency + model ±3 GB + login Cloudflare + tunnel + DNS ai.<domain>
bash scripts/laptop-ai.sh run     # setiap demo (biarkan terminal terbuka)
bash scripts/laptop-ai.sh test    # cek dari internet
```
Sebelum `setup`: **hapus record A `ai`** di Cloudflare DNS (tunnel membuat CNAME-nya sendiri).
`EKYC_AI_API_KEY` di laptop harus sama dengan di server.

**Di server** (`.env` infra):
```
EKYC_PROVIDER=fastapi
EKYC_FASTAPI_URL=https://ai.<domain>
EKYC_WITH_MODELS=false          # service ekyc-ai di server = cadangan mode stub
OCR_ENGINE=stub
FACE_MATCH_ENGINE=stub
LIVENESS_ENGINE=stub
SELFIE_KTP_ENGINE=stub
NANONETS_PRELOAD_ON_START=false
EKYC_FASTAPI_TIMEOUT=90         # Cloudflare memutus respons > 100 dtk
```
Laptop mati / tunnel putus → eKYC error. Cadangan cepat: set `EKYC_FASTAPI_URL=http://ekyc-ai:8000`
lalu `docker compose up -d api` (kembali ke stub). Alternatif tanpa Cloudflare: `ngrok http 8001`
(URL berubah tiap dijalankan → update `EKYC_FASTAPI_URL`).

## 7. Build & jalankan
```bash
cd /opt/victoria/sekuritas-infra
docker compose up -d --build        # build pertama 15–25 menit (llama-cpp-python di-compile)
docker compose ps
docker compose logs -f api          # tunggu "Application ready!" (migrate + seed otomatis)
docker compose logs -f ekyc-ai      # mode A: tunggu model selesai di-load
```
Cek dari VPS:
```bash
curl http://127.0.0.1:8080/api/health        # {"status":"ok",...}
curl -I http://127.0.0.1:3000                # 200
curl -I http://127.0.0.1:3001                # 200
docker compose exec ekyc-ai curl -s localhost:8000/health   # {"status":"ok","service":"ekyc-ai"}
# Mode A — pastikan engine asli terpasang (field "engine" di respons ≠ "stub"):
docker compose cp ../sekuritas-infra/design/ktp.jpeg ekyc-ai:/tmp/ktp.jpeg 2>/dev/null || true
docker compose exec ekyc-ai sh -c 'curl -s -H "X-Api-Key: $EKYC_AI_API_KEY" -F file=@/tmp/ktp.jpeg localhost:8000/ocr'
```

## 8. Nginx + HTTPS
```bash
cat > /etc/nginx/sites-available/victoria <<'EOF'
server { server_name app.domainkamu.com; location / { proxy_pass http://127.0.0.1:3000; proxy_set_header Host $host; } }
server { server_name cms.domainkamu.com; location / { proxy_pass http://127.0.0.1:3001; proxy_set_header Host $host; } }
server {
  server_name api.domainkamu.com;
  client_max_body_size 10m;
  proxy_read_timeout 300s;             # OCR di CPU bisa > 60 detik
  location / {
    proxy_pass http://127.0.0.1:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
EOF
sed -i 's/domainkamu.com/DOMAIN_ASLI.com/g' /etc/nginx/sites-available/victoria
ln -s /etc/nginx/sites-available/victoria /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
certbot --nginx -d app.DOMAIN_ASLI.com -d cms.DOMAIN_ASLI.com -d api.DOMAIN_ASLI.com
```

## 9. Uji akhir (checklist sebelum demo)
- [ ] `https://api.DOMAIN/api/health` → ok
- [ ] `https://app.DOMAIN` tampil, katalog reksa dana terisi (10 produk Victoria / 5 produk Danapathi)
- [ ] `https://cms.DOMAIN` → login Super Admin (`superadmin@danapathi-demo.id` atau `admin@sekuritas-demo.id` / `Admin@123456`) — daftar lengkap akun di `TUTORIAL_DEMO_EKYC.md`
- [ ] Daftar akun baru → email aktivasi masuk (atau ambil dari log:
      `docker compose exec api grep -o 'aktivasi?token=[A-Za-z0-9]*' storage/logs/laravel.log | tail -1`)
- [ ] eKYC: foto KTP → data terbaca otomatis (mode A) → submit → masuk CMS → Approve → Kirim ke S-INVEST
- [ ] Kamera terbuka di HP (butuh HTTPS)

## Operasional
```bash
cd /opt/victoria/sekuritas-infra
# Update kode lalu redeploy
for r in ../sekuritas-*; do git -C $r pull; done && docker compose up -d --build
# Reset data demo (hapus semua & seed ulang)
docker compose exec api php artisan migrate:fresh --seed --force
# Lihat log
docker compose logs -f --tail=100 api
```

## Troubleshooting
| Gejala | Penyebab / solusi |
|---|---|
| Web tampil tapi data kosong / CORS | `PUBLIC_API_ORIGIN` salah saat build → perbaiki `.env`, lalu `docker compose up -d --build frontend cms` (URL API di-bake saat build) |
| Upload KTP "timeout" | Naikkan `EKYC_FASTAPI_TIMEOUT` & `proxy_read_timeout`; cek `docker compose logs ekyc-ai` |
| ekyc-ai restart terus / `Killed` | RAM kurang → tambah swap / upgrade ke 8 GB, atau pakai mode B |
| Link di email mengarah ke domain salah | `PUBLIC_FRONTEND_URL` → `docker compose up -d api` |
| Tombol kamera tidak muncul / izin ditolak | Halaman belum HTTPS |
| Link referral promo di CMS mengarah ke localhost | `PUBLIC_FRONTEND_URL` → `docker compose up -d --build cms` |

## Mobile (APK)
APK lama mengarah ke `https://api.hamztech.my.id/api` (server lama). Build ulang ke domain baru:
```bash
cd sekuritas-mobile
flutter build apk --release --dart-define=API_BASE=https://api.DOMAIN_ASLI.com/api
```

## Keamanan
- `ekyc-ai` & `postgres` tidak diekspos ke internet (hanya jaringan internal Docker).
- `prompt deploy server.md` versi lama pernah memuat `EKYC_AI_API_KEY` asli di git — **jangan dipakai lagi**, selalu generate baru (langkah 6).
- Ganti password akun demo sebelum dipakai data nasabah sungguhan.
