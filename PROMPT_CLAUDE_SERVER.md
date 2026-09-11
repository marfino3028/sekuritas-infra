# Prompt untuk Claude Code di VPS baru

Cara pakai:
1. SSH ke VPS sebagai root → install Claude Code: `curl -fsSL https://claude.ai/install.sh | bash` lalu jalankan `claude`.
2. Ganti nilai `<...>` di bawah (domain, email, mode, versi, SMTP), lalu tempel SELURUH blok prompt ke Claude.

---

```
Kamu di VPS Ubuntu baru (root). Tugas: deploy platform reksa dana (Victoria Sekuritas atau versi Danapathi)
(Laravel API + FastAPI eKYC AI + 2 Nuxt SPA + Postgres) pakai Docker Compose, lalu verifikasi.

DATA:
- Domain utama     : <DOMAIN>              (mis. victoria-demo.com)
- Subdomain        : app.<DOMAIN> (web nasabah), cms.<DOMAIN> (admin), api.<DOMAIN> (API)
- Email certbot    : <EMAIL_CERTBOT>
- Mode eKYC        : <A atau B>            (A = AI asli, butuh RAM available ≥ 5 GB; B = stub tanpa AI)
- Versi/brand      : <victoria atau danapathi>
- SMTP (opsional)  : <host|port|user|pass|from>  atau "log" kalau belum ada

PANDUAN RESMI: setelah clone, baca /opt/victoria/sekuritas-infra/DEPLOY_VPS.md dan ikuti
langkah 3–9 PERSIS. Ringkasnya:
1. Cek resource dulu (nproc, free -h, df -h, docker ps / ss -tlnp untuk port & app lain yang sudah jalan).
   Mode A butuh RAM "available" ≥ 5 GB; kalau kurang → STOP & lapor. Port 80/443/3000/3001/8080 yang
   sudah dipakai app lain → pakai API_PORT/WEB_PORT/CMS_PORT lain di .env, jangan matikan app orang lain.
2. Install git, nginx, certbot (python3-certbot-nginx), curl, ufw, Docker (get.docker.com).
   Buat swap 4 GB bila belum ada. ufw: allow OpenSSH + 'Nginx Full'.
3. Clone ke /opt/victoria (SEJAJAR) dengan GIT_LFS_SKIP_SMUDGE=1:
   sekuritas-infra, sekuritas-api, sekuritas-ai, sekuritas-frontend, sekuritas-cms
   dari https://github.com/marfino3028/<repo>.git
   Versi danapathi: checkout branch `danapathi` di sekuritas-api, sekuritas-frontend, sekuritas-cms
   (ai & infra tetap main), dan di .env set APP_NAME="Danapathi API", MAIL_FROM_NAME="Danapathi Asset Management".
4. Mode A: bash /opt/victoria/sekuritas-ai/scripts/download_models.sh (±3 GB).
5. cd /opt/victoria/sekuritas-infra && cp .env.example .env, lalu isi:
   - APP_KEY=base64:$(openssl rand -base64 32), JWT_SECRET & EKYC_AI_API_KEY = openssl rand -hex 32
   - DB_PASSWORD = openssl rand -hex 16
   - PUBLIC_API_ORIGIN=https://api.<DOMAIN>, PUBLIC_FRONTEND_URL=https://app.<DOMAIN>, PUBLIC_CMS_URL=https://cms.<DOMAIN>
   - SMTP bila diberikan (MAIL_MAILER=smtp ...), kalau tidak biarkan MAIL_MAILER=log
   - Mode B: EKYC_WITH_MODELS=false, OCR_ENGINE=stub, FACE_MATCH_ENGINE=stub, LIVENESS_ENGINE=stub,
     SELFIE_KTP_ENGINE=stub, NANONETS_PRELOAD_ON_START=false
   Simpan salinan secret ke /root/victoria-secrets.txt (chmod 600). JANGAN tampilkan secret di chat.
6. Kalau RAM available < 3 GB: `COMPOSE_PARALLEL_LIMIT=1 docker compose build` dulu, lalu
   `docker compose up -d`. Selain itu: docker compose up -d --build (bisa 15–25 menit). Pantau: docker compose ps, logs api (tunggu
   "Application ready!"), logs ekyc-ai (mode A: model ter-load tanpa ImportError/Killed).
7. Buat /etc/nginx/sites-available/victoria sesuai DEPLOY_VPS.md langkah 8 (api: client_max_body_size 10m,
   proxy_read_timeout 300s), enable, nginx -t, reload, lalu
   certbot --nginx --non-interactive --agree-tos -m <EMAIL_CERTBOT> -d app.<DOMAIN> -d cms.<DOMAIN> -d api.<DOMAIN>
   (Pastikan dulu DNS A-record ketiga subdomain sudah mengarah ke IP VPS: dig +short app.<DOMAIN>.)
8. VERIFIKASI & LAPORKAN hasil nyata tiap poin (jangan diasumsikan):
   a. curl https://api.<DOMAIN>/api/health → status ok
   b. curl -s https://api.<DOMAIN>/api/products | cek ada 10 produk (victoria) atau 5 produk (danapathi)
   c. curl -I https://app.<DOMAIN> dan https://cms.<DOMAIN> → 200
   d. Login semua akun demo (password: Admin@123456 / Ops@123456 / Member@123):
      - CMS  POST /api/cms/auth/login : superadmin@danapathi-demo.id & ops@danapathi-demo.id
        (versi victoria: admin@sekuritas-demo.id & ops@sekuritas-demo.id)
      - Web  POST /api/auth/login-email : member@... (status active) & member.baru@... (belum KYC)
      Catatan: endpoint auth dibatasi 10 request/menit — beri jeda bila kena 429.
   e. Alur nasabah via API: POST /api/auth/register-email (email acak, password Rahasia123) →
      ambil token aktivasi dari DB (docker compose exec postgres psql -U victoria -d victoria -c
      "select activation_token from users where email='...'") → POST /api/auth/activate →
      POST /api/auth/login-email → POST /api/ekyc/session → POST /api/ekyc/ocr (file
      /opt/victoria/sekuritas-infra/design/ktp.jpeg) → laporkan field nik/name/engine yang terbaca.
      Mode A: engine OCR harus BUKAN "stub".
   f. docker compose ps → semua service Up; free -h setelah semua jalan.
9. Kalau ada error: baca log, perbaiki konfigurasi di server (.env / nginx). Kalau yang salah KODE di
   repo, jelaskan perubahan yang dibutuhkan (file + diff) — jangan push ke GitHub.

Laporan akhir: URL ketiga subdomain, mode eKYC & engine aktif, hasil poin 8a–8f, penggunaan RAM/disk,
dan lokasi file secret.
```

---

## Setelah server jalan
- Build ulang APK mobile ke API baru: `flutter build apk --release --dart-define=API_BASE=https://api.<DOMAIN>/api`
- Update kode: `cd /opt/victoria/sekuritas-infra && for r in ../sekuritas-*; do git -C $r pull; done && docker compose up -d --build`
- Reset data demo: `docker compose exec api php artisan migrate:fresh --seed --force`
