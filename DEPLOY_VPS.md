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

# Firewall: hanya SSH + HTTP/HTTPS
ufw allow OpenSSH && ufw allow 'Nginx Full' && ufw --force enable
```

## 4. Clone semua repo (sejajar)
```bash
mkdir -p /opt/victoria && cd /opt/victoria
for r in sekuritas-infra sekuritas-api sekuritas-ai sekuritas-frontend sekuritas-cms; do
  GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/marfino3028/$r.git
done
```
`GIT_LFS_SKIP_SMUDGE=1` = aset desain (gif/png besar di `sekuritas-infra/design`) tidak ikut diunduh — server tidak butuh.

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
- [ ] `https://app.DOMAIN` tampil, katalog reksa dana terisi (10 produk)
- [ ] `https://cms.DOMAIN` → login `admin@sekuritas-demo.id` / `Admin@123456`
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
