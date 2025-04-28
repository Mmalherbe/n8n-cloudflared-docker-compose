
# n8n Cloudflare Docker Setup 🚀

Automate your workflows with **n8n**, an open-source workflow automation tool, using **Docker** and **Cloudflare Tunnel**. 
This repository provides an easy way to deploy an **n8n** instance with **Cloudflare** protection using **Docker Compose**.

## 🌐 What is n8n?
**n8n** is an open-source workflow automation tool that lets you automate repetitive tasks and integrate with over 200+ applications. 
It provides a powerful, visual interface for designing workflows and supports complex business logic.

## 🐳 What is Docker?
**Docker** is a platform that automates the deployment, scaling, and management of applications in isolated environments called containers. 
By using Docker, you can ensure consistency across development, testing, and production environments.

## ☁️ What is Cloudflare Tunnel?
**Cloudflare Tunnel** (formerly Argo Tunnel) allows you to securely expose your local web applications to the internet without needing to open ports or configure firewalls. 
This setup ensures your n8n instance is protected by Cloudflare's security layer.

---

## 🚀 Quick Start

### 🛠 Prerequisites
Make sure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Cloudflare Account](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

### 📝 Setup Instructions

#### 1. Clone this Repository
```bash
git clone https://github.com/yourusername/n8n-cloudflare-docker-setup.git
cd n8n-cloudflare-docker-setup
```

#### 2. Run the Setup Script

Choose your OS:
- Windows: `setup-n8n.bat`
- Linux/macOS: `setup-n8n.sh`

The script will prompt you for:

- Your desired subdomain (e.g., `n8n.example.com`)
- An admin password

It will then:

- Configure your environment files (.env)
- Generate your Docker Compose setup
- Create your Cloudflare tunnel credentials

#### 3. Cloudflare Authentication
- The script will run `cloudflared tunnel login`
- Authenticate through the browser to authorize the tunnel creation.

#### 4. Start n8n
After setup, containers are automatically started. 
To start manually later:
```bash
docker-compose up -d
```

Access your instance via: `https://your-subdomain`

---

## 📜 Project Structure
```
n8n-cloudflare-docker-setup/
├── README.md
├── setup-n8n.bat
├── setup-n8n.sh
├── n8n-docker/
│   ├── .env
│   ├── docker-compose.yml
│   └── cloudflared/
│       ├── config.yml
│       └── n8n-tunnel.json
```

---

## 🔧 Troubleshooting

### ❌ Docker Compose Errors
- **Message**: Docker Compose failed to start.
- **Solution**: Ensure Docker Engine is running and Docker Compose is installed.

### ❌ Cloudflare Login Issues
- **Message**: Cloudflare login failed.
- **Solution**: Ensure you are logged into the correct Cloudflare account in your browser.

### ❌ Missing Tunnel Credentials
- **Message**: Couldn't find tunnel credentials.
- **Solution**: Check if credentials were placed inside the `cloudflared/` directory.

### 🔒 Security Notice
Always secure your server and use SSL (Cloudflare provides this automatically) to protect your credentials and data.

---

## 💬 Need Help?
Open an [Issue](https://github.com/yourusername/n8n-cloudflare-docker-setup/issues) if you encounter problems. 
You can also search the exact error message in Google or check the relevant documentation linked below.

---

## 🔗 Resources
- [n8n Documentation](https://n8n.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

---

Built with ❤️ to simplify workflow automation deployments!
