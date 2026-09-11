# Prompt untuk Claude Code di server

Repo ini **publik** — jangan tulis IP/port SSH, password, atau API key di file ini.
Versi terisi untuk server kamu disimpan lokal di `PROMPT_SERVER_LOKAL.md` (di-ignore git).

Cara pakai:
1. SSH ke server sebagai root → install Claude Code: `curl -fsSL https://claude.ai/install.sh | bash` lalu `claude`.
2. Ganti semua `<...>` di bawah, lalu tempel SELURUH blok prompt ke Claude.

---

```
Kamu di server Ubuntu (root). Tugas: deploy platform reksa dana (repo sekuritas-*) pakai Docker Compose,
lalu verifikasi. Server ini MUNGKIN sudah menjalankan aplikasi lain — jangan ubah/matikan apa pun
yang bukan milik project ini.

DATA:
- Domain            : web nasabah <WEB_HOST> · CMS <CMS_HOST> · API <API_HOST>   (mis. demo./cms./api.domain)
- Email certbot     : <EMAIL_CERTBOT>
- Port SSH server   : <SSH_PORT>
- Versi/brand       : <victoria atau danapathi>
- Mode eKYC         : <A | B | C>
    A = AI asli di server (RAM available ≥ 5 GB)
    B = stub tanpa AI
    C = hybrid: AI asli di laptop via Cloudflare Tunnel <AI_URL> (mis. https://ai.domain); server = cadangan stub
- Password akun demo: admin <DEMO_ADMIN_PASSWORD> · ops <DEMO_OPS_PASSWORD> · member <DEMO_MEMBER_PASSWORD>
- SMTP (opsional)   : <host|port|user|pass|from>  atau "log"

PANDUAN RESMI: setelah clone, baca /opt/victoria/sekuritas-infra/DEPLOY_VPS.md. Ringkasnya:

1. Survei dulu, JANGAN ubah apa pun: nproc, free -h, df -h, docker ps -a, ss -tlnp, ls /etc/nginx/sites-enabled,
   systemctl is-active nginx apache2 caddy, ufw status. Laporkan app lain yang sudah jalan & port yang terpakai.
   Mode A dan RAM available < 5 GB → STOP & lapor.
2. Install yang BELUM ada saja: git, nginx, certbot + python3-certbot-nginx, curl, Docker (get.docker.com).
   Swap: kalau belum ada, buat 4 GB. Firewall: kalau ufw dipakai, pastikan `ufw allow <SSH_PORT>/tcp` SEBELUM
   perubahan lain (SSH bukan port 22!), lalu allow 'Nginx Full'. Jangan disable/reset aturan yang sudah ada.
3. Clone ke /opt/victoria (SEJAJAR) dengan GIT_LFS_SKIP_SMUDGE=1: sekuritas-infra, sekuritas-api, sekuritas-ai,
   sekuritas-frontend, sekuritas-cms dari https://github.com/marfino3028/<repo>.git.
   Versi danapathi: `git checkout danapathi` di sekuritas-api, sekuritas-frontend, sekuritas-cms (ai & infra tetap main).
4. Mode A saja: bash /opt/victoria/sekuritas-ai/scripts/download_models.sh (±3 GB).
5. cd /opt/victoria/sekuritas-infra && cp .env.example .env, lalu isi:
   - APP_KEY=base64:$(openssl rand -base64 32); JWT_SECRET = $(openssl rand -hex 32); DB_PASSWORD = $(openssl rand -hex 16)
   - EKYC_AI_API_KEY = $(openssl rand -hex 32)  (mode C: pakai nilai yang diberikan user bila ada)
   - PUBLIC_API_ORIGIN=https://<API_HOST>, PUBLIC_FRONTEND_URL=https://<WEB_HOST>, PUBLIC_CMS_URL=https://<CMS_HOST>
   - DEMO_ADMIN_PASSWORD / DEMO_OPS_PASSWORD / DEMO_MEMBER_PASSWORD dari DATA
   - Versi danapathi: APP_NAME="Danapathi API", MAIL_FROM_NAME="Danapathi Asset Management"
   - SMTP bila diberikan, kalau tidak MAIL_MAILER=log
   - Mode B & C: EKYC_WITH_MODELS=false, OCR_ENGINE=stub, FACE_MATCH_ENGINE=stub, LIVENESS_ENGINE=stub,
     SELFIE_KTP_ENGINE=stub, NANONETS_PRELOAD_ON_START=false
   - Mode C tambahan: EKYC_PROVIDER=fastapi, EKYC_FASTAPI_URL=<AI_URL>, EKYC_FASTAPI_TIMEOUT=90
   - Port 8080/3000/3001 sudah dipakai app lain → set API_PORT/WEB_PORT/CMS_PORT ke port bebas (tetap BIND_IP=127.0.0.1)
   Simpan semua secret ke /root/victoria-secrets.txt (chmod 600). Jangan tampilkan secret di chat
   KECUALI EKYC_AI_API_KEY pada mode C bila kamu yang meng-generate (user perlu memasangnya di laptop).
6. Build & jalankan (nama project compose "victoria", tidak bentrok dgn container lain):
   RAM available < 3 GB → `COMPOSE_PARALLEL_LIMIT=1 docker compose build` lalu `docker compose up -d`;
   selain itu `docker compose up -d --build`. Pantau `docker compose logs -f api` sampai "Application ready!".
7. Nginx: buat file BARU /etc/nginx/sites-available/victoria (jangan sentuh site lain) sesuai DEPLOY_VPS.md langkah 8
   dengan host & port dari langkah 5 (API: client_max_body_size 10m, proxy_read_timeout 300s). nginx -t, reload.
   Pastikan DNS sudah mengarah ke IP server ini (dig +short <WEB_HOST>) — kalau belum, STOP di sini & lapor.
   Lalu: certbot --nginx --non-interactive --agree-tos -m <EMAIL_CERTBOT> -d <WEB_HOST> -d <CMS_HOST> -d <API_HOST>
8. VERIFIKASI & LAPORKAN hasil nyata (jangan diasumsikan). Endpoint auth dibatasi 10 req/menit — beri jeda bila 429.
   a. curl https://<API_HOST>/api/health → ok
   b. curl -s https://<API_HOST>/api/products → 10 produk (victoria) / 5 produk (danapathi)
   c. curl -I https://<WEB_HOST> & https://<CMS_HOST> → 200
   d. Login CMS (POST /api/cms/auth/login) Super Admin & Ops; login web (POST /api/auth/login-email) member@… & member.baru@…
      Email: victoria = admin@/ops@/member@/member.baru@sekuritas-demo.id; danapathi = superadmin@/ops@/member@/member.baru@danapathi-demo.id
   e. Alur eKYC: register-email (email acak) → ambil activation_token dari DB
      (docker compose exec postgres psql -U victoria -d victoria -c "select activation_token from users where email='...'")
      → /api/auth/activate → /api/auth/login-email → /api/ekyc/session → /api/ekyc/ocr (file /opt/victoria/sekuritas-infra/design/ktp.jpeg).
      Mode A/C: laporkan nik/name yang terbaca (mode C hanya bila laptop sedang menjalankan AI; kalau tidak, cukup laporkan).
   f. docker compose ps → semua Up; free -h setelah jalan; pastikan app lain di server masih jalan seperti di langkah 1.
9. Error → baca log, perbaiki konfigurasi (.env / nginx). Kalau yang salah KODE di repo, jelaskan perubahan (file + diff) — jangan push.

Laporan akhir: URL, mode eKYC, hasil 8a–8f, RAM/disk, port yang dipakai, lokasi file secret.
```

---

## Setelah server jalan
- Build ulang APK mobile ke API baru: `flutter build apk --release --dart-define=API_BASE=https://<API_HOST>/api`
- Update kode: `cd /opt/victoria/sekuritas-infra && for r in ../sekuritas-*; do git -C $r pull; done && docker compose up -d --build`
- Reset data demo: `docker compose exec api php artisan migrate:fresh --seed --force`
