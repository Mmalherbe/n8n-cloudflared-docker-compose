@echo off
setlocal enabledelayedexpansion

:: ──────────────────────────────
:: Step 0 - Ask for user input
:: ──────────────────────────────
echo [STEP 0] User Input
set /p SUBDOMAIN=Enter your full subdomain for n8n (e.g. n8n.example.com): 
if "%SUBDOMAIN%"=="" (
    echo ❌ ERROR: No subdomain entered. [ERROR_NO_SUBDOMAIN]
    exit /b 1
)

set /p PASSWORD=Enter a password for n8n basic auth login (username will be 'admin'): 
if "%PASSWORD%"=="" (
    echo ❌ ERROR: No password entered. [ERROR_NO_PASSWORD]
    exit /b 1
)

:: ──────────────────────────────
:: Step 1 - Create directories
:: ──────────────────────────────
echo [STEP 1] Creating directories...
mkdir n8n-docker\cloudflared 2>nul
cd n8n-docker || (
    echo ❌ ERROR: Failed to create or enter project directory. [ERROR_PROJECT_FOLDER]
    exit /b 1
)

:: ──────────────────────────────
:: Step 2 - Create .env file
:: ──────────────────────────────
echo [STEP 2] Writing .env file...
(
echo N8N_BASIC_AUTH_ACTIVE=true
echo N8N_BASIC_AUTH_USER=admin
echo N8N_BASIC_AUTH_PASSWORD=%PASSWORD%
echo N8N_HOST=localhost
echo N8N_PORT=5678
echo N8N_EDITOR_BASE_URL=http://localhost:5678
echo GENERIC_TIMEZONE=UTC
echo TZ=UTC
echo POSTGRES_USER=n8n
echo POSTGRES_PASSWORD=n8npass
echo POSTGRES_DB=n8ndb
) > .env || (
    echo ❌ ERROR: Failed to write .env file. [ERROR_WRITE_ENV]
    exit /b 1
)

:: ──────────────────────────────
:: Step 3 - Write docker-compose.yml
:: ──────────────────────────────
echo [STEP 3] Creating docker-compose.yml...
(
echo version: '3.7'
echo.
echo services:
echo   postgres:
echo     image: postgres:15
echo     container_name: n8n_postgres
echo     restart: always
echo     environment:
echo       POSTGRES_USER: ^${POSTGRES_USER}
echo       POSTGRES_PASSWORD: ^${POSTGRES_PASSWORD}
echo       POSTGRES_DB: ^${POSTGRES_DB}
echo     volumes:
echo       - postgres_data:/var/lib/postgresql/data
echo.
echo   n8n:
echo     image: n8nio/n8n
echo     container_name: n8n
echo     restart: always
echo     ports:
echo       - "5678:5678"
echo     depends_on:
echo       - postgres
echo     environment:
echo       - DB_TYPE=postgresdb
echo       - DB_POSTGRESDB_HOST=postgres
echo       - DB_POSTGRESDB_PORT=5432
echo       - DB_POSTGRESDB_DATABASE=^${POSTGRES_DB}
echo       - DB_POSTGRESDB_USER=^${POSTGRES_USER}
echo       - DB_POSTGRESDB_PASSWORD=^${POSTGRES_PASSWORD}
echo       - N8N_BASIC_AUTH_ACTIVE=^${N8N_BASIC_AUTH_ACTIVE}
echo       - N8N_BASIC_AUTH_USER=^${N8N_BASIC_AUTH_USER}
echo       - N8N_BASIC_AUTH_PASSWORD=^${N8N_BASIC_AUTH_PASSWORD}
echo       - N8N_HOST=^${N8N_HOST}
echo       - N8N_PORT=^${N8N_PORT}
echo       - N8N_EDITOR_BASE_URL=^${N8N_EDITOR_BASE_URL}
echo       - TZ=^${TZ}
echo       - GENERIC_TIMEZONE=^${GENERIC_TIMEZONE}
echo     volumes:
echo       - n8n_data:/home/node/.n8n
echo.
echo   cloudflared:
echo     image: cloudflare/cloudflared:latest
echo     container_name: cloudflared
echo     restart: always
echo     depends_on:
echo       - n8n
echo     command: tunnel run
echo     volumes:
echo       - ./cloudflared:/etc/cloudflared
echo.
echo volumes:
echo   postgres_data:
echo   n8n_data:
) > docker-compose.yml || (
    echo ❌ ERROR: Failed to write docker-compose.yml. [ERROR_WRITE_DOCKER_COMPOSE]
    exit /b 1
)

:: ──────────────────────────────
:: Step 4 - Cloudflare login
:: ──────────────────────────────
echo [STEP 4] Opening browser for Cloudflare login...
pause
cloudflared login || (
    echo ❌ ERROR: Cloudflare login failed. [ERROR_CLOUDFLARE_LOGIN_FAILED]
    echo 💡 FIX: Make sure your browser is logged into Cloudflare and you've selected a zone.
    exit /b 1
)

:: ──────────────────────────────
:: Step 5 - Tunnel creation
:: ──────────────────────────────
echo [STEP 5] Creating tunnel named "n8n-tunnel"...
cloudflared tunnel create n8n-tunnel || (
    echo ❌ ERROR: Failed to create tunnel. [ERROR_CREATE_TUNNEL]
    echo 💡 FIX: Check if tunnel with the same name already exists. Use "cloudflared tunnel list"
    exit /b 1
)

:: ──────────────────────────────
:: Step 6 - Copy credentials
:: ──────────────────────────────
echo [STEP 6] Copying credentials file...
set "foundTunnel="
for /f "delims=" %%f in ('dir /b "%USERPROFILE%\.cloudflared\n8n-tunnel*.json" 2^>nul') do (
    copy "%USERPROFILE%\.cloudflared\%%f" cloudflared\n8n-tunnel.json >nul
    set "foundTunnel=1"
    goto :found
)

:found
if not defined foundTunnel (
    echo ❌ ERROR: Couldn't find tunnel credentials. [ERROR_TUNNEL_CREDENTIALS_NOT_FOUND]
    echo 💡 FIX: Check %USERPROFILE%\.cloudflared for the credentials JSON.
    exit /b 1
)

:: ──────────────────────────────
:: Step 7 - Create config.yml
:: ──────────────────────────────
echo [STEP 7] Writing cloudflared\config.yml...
(
echo tunnel: n8n-tunnel
echo credentials-file: /etc/cloudflared/n8n-tunnel.json
echo.
echo ingress:
echo   - hostname: %SUBDOMAIN%
echo     service: http://n8n:5678
echo   - service: http_status:404
) > cloudflared\config.yml || (
    echo ❌ ERROR: Failed to write config.yml. [ERROR_WRITE_CLOUDFLARE_CONFIG]
    exit /b 1
)

:: ──────────────────────────────
:: Step 8 - Start Docker stack
:: ──────────────────────────────
echo [STEP 8] Starting Docker services...
docker compose up -d || (
    echo ❌ ERROR: Docker Compose failed to start. [ERROR_DOCKER_COMPOSE_START]
    echo 💡 FIX: Make sure Docker Desktop is running and compose is installed.
    exit /b 1
)

:: ──────────────────────────────
:: Step 9 - Final instructions
:: ──────────────────────────────
echo.
echo ✅ Setup complete!
echo 🌐 IMPORTANT:
echo - Go to your Cloudflare dashboard.
echo - Create a CNAME record pointing: %SUBDOMAIN% to your tunnel UUID.
echo   (You can find the UUID via `cloudflared tunnel list`)
echo.
echo - Then open https://%SUBDOMAIN% in your browser.
echo - Login with: admin / %PASSWORD%
pause
