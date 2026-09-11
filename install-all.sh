#!/usr/bin/env bash
# Install + setup LOKAL semua komponen Victoria Sekuritas sekaligus.
# Jalankan dari mana saja:  bash sekuritas-infra/install-all.sh
# Butuh: php 8.2+ & composer, node 20 & npm, python 3.11 (opsional), flutter (opsional).
# Repo lain harus di-clone SEJAJAR dengan folder sekuritas-infra.

set -u
INFRA="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$INFRA")"
ok=0; fail=0
step() { echo ""; echo "==================== $1 ===================="; }
done_ok() { echo "✅ $1"; ok=$((ok+1)); }
done_fail() { echo "❌ $1 (dilewati/gagal)"; fail=$((fail+1)); }
have() { command -v "$1" >/dev/null 2>&1; }

# 1) Backend Laravel + .env SQLite + migrate/seed (hanya bila .env belum ada)
step "sekuritas-api  (composer install + setup SQLite)"
if have composer; then
  (
    cd "$ROOT/sekuritas-api" && composer install --no-interaction || exit 1
    if [ ! -f .env ]; then
      cp .env.example .env
      touch database/database.sqlite
      DB="$PWD/database/database.sqlite"
      sed -i.bak -e "s|^DB_CONNECTION=.*|DB_CONNECTION=sqlite|" -e "s|^DB_DATABASE=.*|DB_DATABASE=$DB|" \
        -e "/^DB_HOST=/d" -e "/^DB_PORT=/d" -e "/^DB_USERNAME=/d" -e "/^DB_PASSWORD=/d" \
        -e "s|^MAIL_MAILER=.*|MAIL_MAILER=log|" -e "s|^FILESYSTEM_DISK=.*|FILESYSTEM_DISK=public|" .env && rm -f .env.bak
      php artisan key:generate -n && php artisan jwt:secret --force -n
      php artisan migrate:fresh --seed -n && php artisan storage:link
    else
      echo ".env sudah ada → lewati setup DB (seed ulang: php artisan migrate:fresh --seed)"
    fi
  ) && done_ok "sekuritas-api" || done_fail "sekuritas-api"
else
  done_fail "sekuritas-api — composer tidak ditemukan"
fi

# 2) Web depan (Nuxt)
step "sekuritas-frontend  (npm install)"
if have npm; then
  ( cd "$ROOT/sekuritas-frontend" && npm install \
    && { [ -f .env ] || echo "NUXT_PUBLIC_API_BASE=http://localhost:8000/api" > .env; } ) \
    && done_ok "sekuritas-frontend" || done_fail "sekuritas-frontend"
else
  done_fail "sekuritas-frontend — npm tidak ditemukan"
fi

# 3) CMS (Nuxt)
step "sekuritas-cms  (npm install)"
if have npm; then
  ( cd "$ROOT/sekuritas-cms" && npm install \
    && { [ -f .env ] || printf "NUXT_PUBLIC_API_BASE=http://localhost:8000/api/cms\nNUXT_PUBLIC_FRONTEND_BASE=http://localhost:3000\n" > .env; } ) \
    && done_ok "sekuritas-cms" || done_fail "sekuritas-cms"
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

# 5) AI eKYC (FastAPI) — WAJIB Python 3.11 (3.13/3.14 belum didukung pydantic/insightface)
step "sekuritas-ai  (python 3.11 venv + pip install)"
PY=""
for c in python3.11 "$HOME/.pyenv/versions/3.11.11/bin/python"; do
  if have "$c" || [ -x "$c" ]; then PY="$c"; break; fi
done
if [ -n "$PY" ]; then
  ( cd "$ROOT/sekuritas-ai" \
    && "$PY" -m venv .venv \
    && .venv/bin/pip install --upgrade pip \
    && .venv/bin/pip install -r requirements.txt \
    && { [ -f .env ] || sed -e 's/^OCR_ENGINE=.*/OCR_ENGINE=stub/' -e 's/^FACE_MATCH_ENGINE=.*/FACE_MATCH_ENGINE=stub/' \
           -e 's/^LIVENESS_ENGINE=.*/LIVENESS_ENGINE=stub/' -e 's/^SELFIE_KTP_ENGINE=.*/SELFIE_KTP_ENGINE=stub/' .env.example > .env; } ) \
    && done_ok "sekuritas-ai" || done_fail "sekuritas-ai"
else
  done_fail "sekuritas-ai — python3.11 tidak ditemukan (brew install python@3.11 / pyenv install 3.11.11)"
fi

echo ""
echo "==================== RINGKASAN ===================="
echo "Berhasil: $ok   |   Gagal/dilewati: $fail"
echo ""
echo "Jalankan (3 terminal):"
echo "  cd $ROOT/sekuritas-api && php artisan serve --port=8000"
echo "  cd $ROOT/sekuritas-frontend && npm run dev                 # http://localhost:3000"
echo "  cd $ROOT/sekuritas-cms && npm run dev -- --port 3001       # http://localhost:3001"
echo "Opsional AI: cd $ROOT/sekuritas-ai && .venv/bin/uvicorn app.main:app --port 8001"
