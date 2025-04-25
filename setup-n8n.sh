
#!/bin/bash

# ──────────────────────────────
# Step 0 - Ask for user input
# ──────────────────────────────
echo "[STEP 0] User Input"
read -p "Enter your full subdomain for n8n (e.g. n8n.example.com): " SUBDOMAIN
if [ -z "$SUBDOMAIN" ]; then
    echo "❌ ERROR: No subdomain entered. [ERROR_NO_SUBDOMAIN]"
    exit 1
fi

read -p "Enter a password for n8n basic auth login (username will be 'admin'): " PASSWORD
if [ -z "$PASSWORD" ]; then
    echo "❌ ERROR: No password entered. [ERROR_NO_PASSWORD]"
    exit 1
fi

# ──────────────────────────────
# Step 1 - Create directories
# ──────────────────────────────
echo "[STEP 1] Creating directories..."
mkdir -p n8n-docker/cloudflared || {
    echo "❌ ERROR: Failed to create or enter project directory. [ERROR_PROJECT_FOLDER]"
    exit 1
}
cd n8n-docker || exit 1

# ──────────────────────────────
# Step 2 - Create .env file
# ──────────────────────────────
echo "[STEP 2] Writing .env file..."
cat <<EOL > .env
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=$PASSWORD
N8N_HOST=localhost
N8N_PORT=5678
N8N_EDITOR_BASE_URL=http://localhost:5678
GENERIC_TIMEZONE=UTC
TZ=UTC
POSTGRES_USER=n8n
POSTGRES_PASSWORD=n8npass
POSTGRES_DB=n8ndb
EOL

# ──────────────────────────────
# Step 3 - Write docker-compose.yml
# ──────────────────────────────
echo "[STEP 3] Creating docker-compose.yml..."
cat <<EOL > docker-compose.yml
version: '3.7'

services:
  postgres:
    image: postgres:15
    container_name: n8n_postgres
    restart: always
    environment:
      POSTGRES_USER: \${POSTGRES_USER}
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD}
      POSTGRES_DB: \${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  n8n:
    image: n8nio/n8n
    container_name: n8n
    restart: always
    ports:
      - "5678:5678"
    depends_on:
      - postgres
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=\${POSTGRES_DB}
      - DB_POSTGRESDB_USER=\${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=\${POSTGRES_PASSWORD}
      - N8N_BASIC_AUTH_ACTIVE=\${N8N_BASIC_AUTH_ACTIVE}
      - N8N_BASIC_AUTH_USER=\${N8N_BASIC_AUTH_USER}
      - N8N_BASIC_AUTH_PASSWORD=\${N8N_BASIC_AUTH_PASSWORD}
      - N8N_HOST=\${N8N_HOST}
      - N8N_PORT=\${N8N_PORT}
      - N8N_EDITOR_BASE_URL=\${N8N_EDITOR_BASE_URL}
      - TZ=\${TZ}
      - GENERIC_TIMEZONE=\${GENERIC_TIMEZONE}
    volumes:
      - n8n_data:/home/node/.n8n

  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: always
    depends_on:
      - n8n
    command: tunnel run
    volumes:
      - ./cloudflared:/etc/cloudflared

volumes:
  postgres_data:
  n8n_data:
EOL

# ──────────────────────────────
# Step 4 - Cloudflare login
# ──────────────────────────────
echo "[STEP 4] Opening browser for Cloudflare login..."
read -n 1 -s -r -p "Press any key to continue after logging in..."

cloudflared login || {
    echo "❌ ERROR: Cloudflare login failed. [ERROR_CLOUDFLARE_LOGIN_FAILED]"
    echo "💡 FIX: Make sure your browser is logged into Cloudflare and you've selected a zone."
    exit 1
}

# ──────────────────────────────
# Step 5 - Tunnel creation
# ──────────────────────────────
echo "[STEP 5] Creating tunnel named 'n8n-tunnel'..."
cloudflared tunnel create n8n-tunnel || {
    echo "❌ ERROR: Failed to create tunnel. [ERROR_CREATE_TUNNEL]"
    echo "💡 FIX: Check if tunnel with the same name already exists. Use 'cloudflared tunnel list'"
    exit 1
}

# ──────────────────────────────
# Step 6 - Copy credentials
# ──────────────────────────────
echo "[STEP 6] Copying credentials file..."
CREDENTIALS_FILE=$(find ~/.cloudflared -name "n8n-tunnel*.json" | head -n 1)
if [ -z "$CREDENTIALS_FILE" ]; then
    echo "❌ ERROR: Couldn't find tunnel credentials. [ERROR_TUNNEL_CREDENTIALS_NOT_FOUND]"
    echo "💡 FIX: Check ~/.cloudflared for the credentials JSON."
    exit 1
fi
cp "$CREDENTIALS_FILE" cloudflared/n8n-tunnel.json

# ──────────────────────────────
# Step 7 - Create config.yml
# ──────────────────────────────
echo "[STEP 7] Writing cloudflared/config.yml..."
cat <<EOL > cloudflared/config.yml
tunnel: n8n-tunnel
credentials-file: /etc/cloudflared/n8n-tunnel.json

ingress:
  - hostname: $SUBDOMAIN
    service: http://n8n:5678
  - service: http_status:404
EOL

# ──────────────────────────────
# Step 8 - Start Docker stack
# ──────────────────────────────
echo "[STEP 8] Starting Docker services..."
docker compose up -d || {
    echo "❌ ERROR: Docker Compose failed to start. [ERROR_DOCKER_COMPOSE_START]"
    echo "💡 FIX: Make sure Docker Desktop is running and compose is installed."
    exit 1
}

# ──────────────────────────────
# Step 9 - Final instructions
# ──────────────────────────────
echo
echo "✅ Setup complete!"
echo "🌐 IMPORTANT:"
echo "- Go to your Cloudflare dashboard."
echo "- Create a CNAME record pointing: $SUBDOMAIN to your tunnel UUID."
echo "  (You can find the UUID via 'cloudflared tunnel list')"
echo
echo "- Then open https://$SUBDOMAIN in your browser."
echo "- Login with: admin / $PASSWORD"
