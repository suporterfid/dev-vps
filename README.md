# VPS Development Environment Setup

Complete development environment setup script for Ubuntu 24.04 LTS VPS, optimized for Claude Code and multi-stack development.

## 📦 What Gets Installed

### Core System Tools
- ✅ **tmux** - Terminal multiplexer with custom config
- ✅ **git** - Version control with useful aliases
- ✅ **vim/nano** - Text editors
- ✅ **htop/btop** - System monitoring
- ✅ **ncdu** - Disk usage analyzer
- ✅ **tree, jq, zip/unzip** - File utilities

### Containerization
- ✅ **Docker** - Latest stable version
- ✅ **Docker Compose** - V2 plugin
- ✅ **Docker Buildx** - Multi-platform builds

### Node.js Ecosystem
- ✅ **NVM** v0.39.7 - Node Version Manager
- ✅ **Node.js** v20.19.4 (LTS)
- ✅ **npm** - Latest version
- ✅ **pnpm** - Fast package manager
- ✅ **yarn** - Alternative package manager
- ✅ **PM2** - Process manager
- ✅ **NestJS CLI** - For NestJS projects
- ✅ **TypeScript/ts-node** - TypeScript tooling

### .NET Development
- ✅ **.NET 8 SDK** - Complete development kit
- ✅ **.NET 8 Runtime** - Runtime environment
- ✅ **ASP.NET Core Runtime** - Web development

### Python Environment
- ✅ **Python 3.12** - Latest Ubuntu 24.04 default
- ✅ **pip** - Package installer
- ✅ **venv/virtualenv** - Environment management
- ✅ **pipenv/poetry** - Advanced package managers
- ✅ **IPython/Jupyter** - Interactive shells
- ✅ **black/flake8/pylint** - Code quality tools

### PHP (for Laravel/Neuron AI)
- ✅ **PHP 8.3** - Latest stable
- ✅ **Composer** - Dependency manager
- ✅ **Extensions**: MySQL, PostgreSQL, Redis, GD, curl, XML, BCMath, etc.

### Database Clients
- ✅ **MySQL client**
- ✅ **PostgreSQL client**
- ✅ **Redis CLI**
- ✅ **SQLite**

### Developer Tools
- ✅ **Claude Code CLI** - AI-assisted coding
- ✅ **GitHub CLI (gh)** - GitHub operations
- ✅ **lazygit** - Beautiful Git UI
- ✅ **fd** - Modern find replacement
- ✅ **ripgrep (rg)** - Fast grep alternative
- ✅ **bat** - Cat with syntax highlighting
- ✅ **exa** - Modern ls replacement

### Security
- ✅ **UFW firewall** - Configured with SSH/HTTP/HTTPS
- ✅ **fail2ban** - Intrusion prevention
- ✅ **certbot** - SSL certificate management

## 🚀 Quick Start

### 1. Upload Script to VPS

```bash
# From your local machine (replace with your VPS IP)
scp vps-dev-setup.sh user@your-vps-ip:~/

# OR copy-paste the content directly
nano vps-dev-setup.sh
# Paste content, Ctrl+O to save, Ctrl+X to exit
```

### 2. Make Executable

```bash
chmod +x vps-dev-setup.sh
```

### 3. Run the Script

```bash
./vps-dev-setup.sh
```

⏱️ **Estimated time**: 10-15 minutes depending on connection speed

### 4. Post-Installation Steps

```bash
# 1. Log out and back in (or source bashrc)
source ~/.bashrc

# 2. Verify Node.js installation
node --version  # Should show v20.19.4

# 3. Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 4. Set up SSH keys for GitHub
ssh-keygen -t ed25519 -C "your.email@example.com"
cat ~/.ssh/id_ed25519.pub
# Add to GitHub: https://github.com/settings/keys

# 5. Authenticate Claude Code
claude-code auth

# 6. Test Docker (after re-login)
docker run hello-world
```

## 📁 Workspace Structure

The script creates the following directory structure:

```
~/
├── projects/
│   ├── neuron-ai/          # Neuron AI (PHP/Laravel)
│   ├── leadsense/          # LeadSense CRM
│   ├── rfid/               # RFID projects
│   ├── n8n-workflows/      # n8n automation
│   ├── automation/         # Other automation
│   └── experiments/        # Testing & experiments
├── backups/                # Local backups
├── scripts/                # Utility scripts
└── logs/                   # Application logs
```

## 🎯 Useful Aliases

The script configures these aliases (available after `source ~/.bashrc`):

### Navigation
```bash
..      # cd ..
...     # cd ../..
....    # cd ../../..
```

### Git
```bash
gs      # git status
ga      # git add
gc      # git commit
gp      # git push
gl      # git log --oneline --graph
gco     # git checkout
```

### Docker
```bash
d       # docker
dc      # docker compose
dps     # docker ps
dpa     # docker ps -a
dex     # docker exec -it
dlogs   # docker logs -f
dprune  # docker system prune -af
```

### Node/NPM
```bash
ni      # npm install
ns      # npm start
nt      # npm test
nr      # npm run
pn      # pnpm
```

### Tmux
```bash
ta      # tmux attach -t
tl      # tmux list-sessions
tn      # tmux new -s
```

### System
```bash
ll      # exa -lah (or ls -alh)
lt      # tree view
ports   # netstat -tulanp
usage   # disk usage (du -h -d1)
```

### Claude Code
```bash
cc      # claude-code
```

## 🔧 Tmux Configuration

Custom tmux config with developer-friendly settings:

### Key Bindings
- **Prefix**: `Ctrl+A` (instead of default `Ctrl+B`)
- **Split Horizontal**: `Ctrl+A` then `|`
- **Split Vertical**: `Ctrl+A` then `-`
- **Navigate Panes**: `Ctrl+A` then `h/j/k/l`
- **Reload Config**: `Ctrl+A` then `r`

### Features
- ✅ Mouse support enabled
- ✅ 50,000 line scrollback buffer
- ✅ Window numbering starts at 1
- ✅ Automatic window renumbering
- ✅ 256 color support

### Quick Start with Tmux
```bash
# Create new session
tmux new -s work

# Detach (keep session running)
Ctrl+A, then d

# List sessions
tmux ls

# Reattach to session
tmux attach -t work

# Kill session
tmux kill-session -t work
```

## 📱 iPhone Access Setup

### Option 1: Termius (Recommended)
1. Install Termius from App Store
2. Add new host with VPS IP
3. Configure SSH key authentication
4. Enable "Keep alive" for persistent connections

### Option 2: Blink Shell
1. Install Blink Shell from App Store
2. More terminal-native experience
3. Better for long coding sessions

### Persistent Session Workflow
```bash
# On VPS: Start tmux session
tmux new -s claude-dev

# Start Claude Code
cd ~/projects/neuron-ai
claude-code

# On iPhone: Detach when needed
Ctrl+A, d

# On iPhone: Reattach anytime
ssh user@vps-ip
tmux attach -t claude-dev
```

## 🔒 Security Notes

### Firewall Configuration
The script configures UFW to allow only:
- SSH (port 22)
- HTTP (port 80)
- HTTPS (port 443)

To allow additional ports:
```bash
sudo ufw allow 3000/tcp  # Example: Node.js app
sudo ufw status          # Check current rules
```

### fail2ban
Automatically enabled to protect against brute-force attacks on SSH.

Check status:
```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

### Additional Security Recommendations
```bash
# 1. Change default SSH port (optional)
sudo nano /etc/ssh/sshd_config
# Change: Port 22 → Port 2222
sudo systemctl restart sshd
sudo ufw allow 2222/tcp
sudo ufw delete allow 22/tcp

# 2. Disable password authentication (after SSH keys setup)
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart sshd

# 3. Set up automatic security updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

## 🐛 Troubleshooting

### Docker Permission Denied
**Problem**: `permission denied while trying to connect to the Docker daemon socket`

**Solution**:
```bash
# Log out and log back in to apply group membership
exit
# SSH back in
```

### NVM Command Not Found
**Problem**: `nvm: command not found`

**Solution**:
```bash
source ~/.bashrc
# OR
source ~/.nvm/nvm.sh
```

### Port Already in Use
**Problem**: Application won't start because port is in use

**Solution**:
```bash
# Find process using port (e.g., 3000)
sudo lsof -i :3000
# OR
sudo netstat -tulanp | grep 3000

# Kill the process
sudo kill -9 <PID>
```

### Out of Disk Space
**Problem**: `No space left on device`

**Solution**:
```bash
# Analyze disk usage
ncdu /

# Clean Docker
docker system prune -af

# Clean package cache
sudo apt clean
sudo apt autoclean

# Clean old logs
sudo journalctl --vacuum-time=7d
```

## 📊 System Monitoring

### Check Resource Usage
```bash
# CPU & Memory (interactive)
htop
# OR modern alternative
btop

# Disk usage
df -h
ncdu /

# Docker stats
docker stats

# System info
inxi -F
```

### Check Running Services
```bash
# All services
systemctl list-units --type=service --state=running

# Specific service
systemctl status docker
systemctl status fail2ban
```

## 🔄 Updating the Environment

### Update System Packages
```bash
sudo apt update
sudo apt upgrade -y
```

### Update Node.js
```bash
nvm install 20.19.4  # or newer version
nvm use 20.19.4
nvm alias default 20.19.4
```

### Update Global npm Packages
```bash
npm update -g
```

### Update Docker
```bash
sudo apt update
sudo apt upgrade docker-ce docker-ce-cli containerd.io
```

## 📝 Maintenance Tasks

### Daily
- Check `htop` for resource usage
- Monitor Docker containers: `docker ps`

### Weekly
- Update system: `sudo apt update && sudo apt upgrade`
- Clean Docker: `docker system prune`
- Review logs: `journalctl -xe`

### Monthly
- Review disk usage: `ncdu /`
- Check fail2ban logs: `sudo fail2ban-client status`
- Update all global packages

## 🎓 Learning Resources

### Tmux
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)
- [A Quick and Easy Guide to tmux](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/)

### Docker
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

### Git
- [Git Documentation](https://git-scm.com/doc)
- [lazygit Tutorial](https://github.com/jesseduffield/lazygit/blob/master/docs/Tutorial.md)

## 🆘 Support & Feedback

If you encounter issues:
1. Check troubleshooting section above
2. Review script output for error messages
3. Check system logs: `journalctl -xe`
4. Verify service status: `systemctl status <service>`

## 📄 License

This setup script is provided as-is for development purposes.

---

**Last Updated**: February 2026  
**Target System**: Ubuntu 24.04 LTS  
**Maintained by**: Alex's Development Environment
