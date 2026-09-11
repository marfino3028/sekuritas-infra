# (USANG) Prompt deploy server

File ini dulu berisi langkah deploy ke server bersama lama (sudah habis masa sewanya).
Banyak detailnya sudah tidak cocok (port 8002/8000 bentrok, `NUXT_PUBLIC_API_BASE` memakai
nama container padahal frontend/CMS adalah SPA statis yang dipanggil dari browser,
nama file model mmproj tidak cocok dengan config, dsb.).

➡️ Pakai **`DEPLOY_VPS.md`** (satu `docker-compose.yml`, sudah diuji).

⚠️ Versi lama file ini sempat memuat `EKYC_AI_API_KEY` asli di riwayat git — anggap bocor,
selalu generate kunci baru (`openssl rand -hex 32`).
