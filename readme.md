n8n Cloudflare Docker Setup 🚀

Automate your workflows with n8n, an open-source workflow automation tool, using Docker and Cloudflare Tunnel. This repository provides an easy way to deploy an n8n instance with Cloudflare protection using Docker Compose.

🌐 What is n8n?

n8n is an open-source workflow automation tool that lets you automate repetitive tasks and integrate with over 200+ applications. It provides a powerful, visual interface for designing workflows and supports complex business logic.

🐳 What is Docker?

Docker is a platform that automates the deployment, scaling, and management of applications in isolated environments called containers. By using Docker, you can ensure consistency across development, testing, and production environments.

☁️ What is Cloudflare Tunnel?

Cloudflare Tunnel (formerly Argo Tunnel) allows you to securely expose your local web applications to the internet without needing to open any ports or configure firewalls. This setup ensures that your n8n instance is protected by Cloudflare's security layer.

🚀 Quick Start

🛠 Prerequisites

Before you begin, ensure you have the following installed on your machine:

Docker: Docker is essential to run containers and manage services like n8n, PostgreSQL, and Cloudflare.

Docker Installation Guide

Docker Compose: For orchestrating multiple Docker containers (PostgreSQL, n8n, Cloudflared).

Docker Compose Installation Guide

Cloudflare Account: You'll need a Cloudflare account and a domain for the subdomain you want to point to your n8n instance.

Cloudflare Tunnel Setup Guide

📝 Setup Instructions

1. Clone this Repository

git clone https://github.com/yourusername/n8n-cloudflare-docker-setup.git
cd n8n-cloudflare-docker-setup

2. Choose Your OS Script

For Windows, run setup-n8n.bat

For Linux/macOS, run setup-n8n.sh

The script will guide you through setting up the following:

n8n subdomain: Choose a subdomain like n8n.yourdomain.com for your instance.

Password: Set a secure password for logging into the n8n editor.

Docker Setup: The script will automatically create a docker-compose.yml file and other configuration files for you.

3. Cloudflare Setup

During the setup, you'll be asked to log in to Cloudflare and create a tunnel. This is how it works:

Cloudflare Login: The script will trigger the cloudflared login command, opening your browser to log into your Cloudflare account.

Create Tunnel: The script will create a tunnel called n8n-tunnel, and the connection will be secured by Cloudflare.

Credentials: Cloudflare will generate a credentials file, which the script automatically places into the cloudflared folder.

4. Starting Your n8n Instance

Once the script completes, it will automatically start the Docker containers for:

PostgreSQL: Stores your n8n data.

n8n: Your automation platform.

Cloudflared: Secures your connection and exposes n8n to the internet.

To start everything manually, you can run:

docker-compose up -d

🔧 Troubleshooting

If you run into any issues, the script will provide error messages along with suggestions for resolution. Here are some common problems:

❌ Docker Compose Errors

Error: Docker Compose failed to start

Fix: Make sure Docker Desktop is running and that docker-compose is properly installed.

❌ Cloudflare Login Issues

Error: Cloudflare login failed

Fix: Ensure your browser is logged into Cloudflare and that you have selected a zone (your domain).

❌ Missing Credentials

Error: Couldn't find tunnel credentials

Fix: Verify that Cloudflare generated the credentials file in ~/.cloudflared. You can manually upload it if needed.

🔐 Security Note

Ensure your Cloudflare Tunnel and Docker environment are properly secured with firewalls, authentication, and access controls to prevent unauthorized access.

📜 File Structure

n8n-cloudflare-docker-setup/
├── README.md           # Project documentation
├── setup-n8n.bat       # Windows batch script for setup
├── setup-n8n.sh        # Linux/macOS shell script for setup
├── n8n-docker/         # Docker files and cloudflared folder
│   ├── docker-compose.yml   # Docker Compose configuration
│   ├── .env                 # Environment variables for n8n
│   ├── cloudflared/         # Cloudflare tunnel credentials and config
│   │   └── config.yml       # Cloudflare tunnel config
└── └── n8n-tunnel.json      # Cloudflare Tunnel credentials

💬 Support

If you encounter any issues, feel free to open an issue in this repository or search online using the error messages provided in the script.

🔗 Links

n8n Documentation

Docker Documentation

Cloudflare Tunnel Documentation

Now your n8n instance is live with Cloudflare protection, running on Docker! Enjoy automating your workflows. 🎉

