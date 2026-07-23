#!/usr/bin/env bash
# Install semua dependency Victoria Sekuritas (5 komponen) sekaligus.
# Jalankan dari folder ini:  bash install-all.sh
# Butuh: composer, npm, flutter, python3 (lewati yang tidak ada).

set -u
ROOT="$(cd "$(dirname "$0")" && pwd)"
ok=0; fail=0
step() { echo ""; echo "==================== $1 ===================="; }
done_ok() { echo "✅ $1"; ok=$((ok+1)); }
done_fail() { echo "❌ $1 (dilewati/gagal)"; fail=$((fail+1)); }

have() { command -v "$1" >/dev/null 2>&1; }

# 1) Backend Laravel
step "sekuritas-api  (composer install)"
if have composer; then
  ( cd "$ROOT/sekuritas-api" && composer install --no-interaction ) && done_ok "sekuritas-api" || done_fail "sekuritas-api"
else
  done_fail "sekuritas-api — composer tidak ditemukan"
fi

# 2) Web depan (Nuxt)
step "sekuritas-frontend  (npm install)"
if have npm; then
  ( cd "$ROOT/sekuritas-frontend" && npm install ) && done_ok "sekuritas-frontend" || done_fail "sekuritas-frontend"
else
  done_fail "sekuritas-frontend — npm tidak ditemukan"
fi

# 3) CMS (Nuxt)
step "sekuritas-cms  (npm install)"
if have npm; then
  ( cd "$ROOT/sekuritas-cms" && npm install ) && done_ok "sekuritas-cms" || done_fail "sekuritas-cms"
else
  done_fail "sekuritas-cms — npm tidak ditemukan"
fi

# 4) Mobile (Flutter)
step "sekuritas-mobile  (flutter pub get)"
if have flutter; then
  ( cd "$ROOT/sekuritas-mobile" && flutter pub get ) && done_ok "sekuritas-mobile" || done_fail "sekuritas-mobile"
else
  done_fail "sekuritas-mobile — flutter tidak ditemukan"
fi

# 5) AI eKYC (FastAPI) — venv + pip
step "sekuritas-ai  (python venv + pip install)"
if have python3; then
  ( cd "$ROOT/sekuritas-ai" \
    && python3 -m venv .venv \
    && . .venv/bin/activate \
    && pip install --upgrade pip \
    && pip install -r requirements.txt ) && done_ok "sekuritas-ai" || done_fail "sekuritas-ai"
else
  done_fail "sekuritas-ai — python3 tidak ditemukan"
fi

echo ""
echo "==================== RINGKASAN ===================="
echo "Berhasil: $ok   |   Gagal/dilewati: $fail"
echo ""
echo "Langkah selanjutnya (lihat CARA_MENJALANKAN.md):"
echo "  1. sekuritas-api : cp .env.example .env; php artisan key:generate; php artisan jwt:secret;"
echo "                     php artisan migrate:fresh --seed; php artisan storage:link; php artisan serve --port=8000"
echo "  2. sekuritas-frontend : buat .env (NUXT_PUBLIC_API_BASE=http://localhost:8000/api); npm run dev"
echo "  3. sekuritas-cms      : buat .env (apiBase .../api/cms + frontendBase); npm run dev -- --port 3001"
echo "  4. sekuritas-ai (opsional): source .venv/bin/activate; uvicorn app.main:app --reload --port 8001"
echo "  5. sekuritas-mobile (opsional): flutter run"
