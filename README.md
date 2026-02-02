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

### PHP
- ✅ **PHP 8.3** - Latest stable
- ✅ **Composer** - Dependency manager
- ✅ **Extensions**: MySQL, PostgreSQL, Redis, GD, curl, XML, BCMath, etc.

### Android Development
- ✅ **OpenJDK 17** - Java Development Kit (required for Android)
- ✅ **Android SDK** - Command-line tools for building Android apps
- ✅ **Android Build Tools** 35.0.0 - Latest build tools
- ✅ **Android Platform Tools** - ADB and fastboot
- ✅ **Android Platforms** - SDK platforms 34 & 35
- ✅ **Gradle 8.12** - Build automation tool

### Database Clients
- ✅ **MySQL client**
- ✅ **PostgreSQL client**
- ✅ **Redis CLI**
- ✅ **SQLite**
- ✅ **mongosh** - MongoDB Shell

### Developer Tools
- ✅ **Claude Code CLI** - AI-assisted coding
- ✅ **GitHub CLI (gh)** - GitHub operations
- ✅ **lazygit** - Beautiful Git UI
- ✅ **fd** - Modern find replacement
- ✅ **ripgrep (rg)** - Fast grep alternative
- ✅ **bat** - Cat with syntax highlighting
- ✅ **exa** - Modern ls replacement

### AI CLI Tools
- ✅ **Shell-GPT (sgpt)** - Simple CLI assistant for quick commands
- ✅ **Aider** - AI pair programming tool
- ✅ **Ollama** - Local LLM runtime for offline AI
- ✅ **GitHub Copilot CLI** - GitHub's AI CLI extension
- ✅ **Codex CLI** - OpenAI's code assistant

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
│   ├── web/                # Web application projects
│   ├── api/                # API/Backend projects
│   ├── mobile/             # Mobile app projects
│   ├── automation/         # Automation scripts
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

### AI Tools
```bash
ai      # aider
aic     # aider --model sonnet
aig     # aider --model gpt-4o
ask     # sgpt (Shell-GPT)
ollama-code  # ollama run deepseek-coder
```

### AI Helper Functions
```bash
ask-cmd '<query>'   # Get shell commands from AI
ask-code '<query>'  # Generate code from AI
gac                 # Git add all + AI commit review
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
cd ~/projects/web
claude-code

# On iPhone: Detach when needed
Ctrl+A, d

# On iPhone: Reattach anytime
ssh user@vps-ip
tmux attach -t claude-dev
```

## 🤖 Android Development

This setup includes a complete Android development environment for building Android apps via command line over SSH.

### Environment Variables

The following environment variables are configured:
```bash
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ANDROID_HOME=$HOME/Android/Sdk
ANDROID_SDK_ROOT=$HOME/Android/Sdk
```

### Building an Android App

```bash
# Navigate to your Android project
cd ~/projects/mobile/my-android-app

# Build debug APK
./gradlew assembleDebug

# Build release APK
./gradlew assembleRelease

# Build and install on connected device (via ADB over network)
./gradlew installDebug

# Run all tests
./gradlew test

# Clean and rebuild
./gradlew clean build
```

### Managing Android SDK

```bash
# List installed packages
sdkmanager --list_installed

# List available packages
sdkmanager --list

# Install additional SDK platforms
sdkmanager "platforms;android-33"
sdkmanager "build-tools;34.0.0"

# Update all installed packages
sdkmanager --update

# Accept licenses
sdkmanager --licenses
```

### ADB Commands

```bash
# List connected devices
adb devices

# Connect to device over network (useful for remote development)
adb connect <device-ip>:5555

# Install APK
adb install app-debug.apk

# Uninstall app
adb uninstall com.example.myapp

# View logs
adb logcat

# Copy files from/to device
adb push local-file.txt /sdcard/
adb pull /sdcard/file.txt ./
```

### Creating a New Android Project

```bash
# Using Gradle init (basic)
mkdir my-android-app && cd my-android-app
gradle init --type basic

# For a complete Android project, clone a template or use Android Studio
# on your local machine, then push to git and clone on VPS
```

### React Native / Expo (Android)

```bash
# Build React Native Android app
cd my-react-native-app
npx react-native build-android --mode=release

# Expo projects
npx expo prebuild --platform android
cd android && ./gradlew assembleRelease
```

### Flutter (Android)

```bash
# Install Flutter (if needed)
git clone https://github.com/flutter/flutter.git ~/flutter
export PATH="$PATH:$HOME/flutter/bin"
flutter doctor

# Build Flutter Android app
cd my-flutter-app
flutter build apk --release
flutter build appbundle --release
```

### Useful Gradle Options

```bash
# Build with increased memory
./gradlew assembleDebug -Dorg.gradle.jvmargs="-Xmx4g"

# Parallel builds
./gradlew assembleDebug --parallel

# Offline mode (faster if dependencies cached)
./gradlew assembleDebug --offline

# Skip tests
./gradlew assembleDebug -x test

# Verbose output
./gradlew assembleDebug --info
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

## 🤖 AI Tools Workflow

This environment includes multiple AI CLI tools for different development scenarios.

### Initial Setup

Configure API keys for AI services:
```bash
# Add to ~/.bashrc for persistence
export OPENAI_API_KEY='your-openai-key'       # For Shell-GPT, Aider with GPT
export ANTHROPIC_API_KEY='your-anthropic-key' # For Aider with Claude

# Download local models for Ollama (optional, for offline use)
ollama pull deepseek-coder    # Best for coding tasks
ollama pull llama3            # General purpose
ollama pull codellama         # Code completion
```

### Recommended Workflow

#### For Daily Development:
```bash
# 1. Start a tmux session
tmux new -s dev

# 2. Use Claude Code for large tasks
claude-code

# 3. Use Aider for quick refactoring
aider app.py tests.py

# 4. Use Ollama for offline queries
ollama run deepseek-coder "explain this pattern"

# 5. Use Shell-GPT for quick commands
sgpt "find all TODO comments"
```

#### For Specific Tasks:

**Refactoring:**
```bash
aider --model sonnet app/
```

**Test Generation:**
```bash
aider tests/ --message "add tests for UserController"
```

**Bug Fixing:**
```bash
claude-code  # For deep context understanding
```

**Quick Commands:**
```bash
sgpt --code "bash script to backup database"
```

### Tool Comparison

| Tool | Best For | Requires API Key | Offline Support |
|------|----------|------------------|-----------------|
| Claude Code | Complex tasks, deep context | Anthropic | No |
| Aider | Pair programming, refactoring | OpenAI/Anthropic | No |
| Shell-GPT | Quick queries, commands | OpenAI | No |
| Ollama | Offline work, local models | None | Yes |
| GitHub Copilot | GitHub integration | GitHub | No |

### AI Aliases Quick Reference

```bash
# AI Tools
cc              # Claude Code
ai / aider      # Aider
aic             # Aider with Claude Sonnet
aig             # Aider with GPT-4o
ask / sgpt      # Shell-GPT
ollama-code     # Ollama with deepseek-coder

# Helper Functions
ask-cmd '<query>'   # Get shell command suggestions
ask-code '<query>'  # Generate code snippets
gac                 # Git add all + AI-assisted commit
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

### Android SDK Commands Not Found
**Problem**: `sdkmanager: command not found` or similar

**Solution**:
```bash
# Reload shell configuration
source ~/.bashrc

# Or manually add to path
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
```

### Gradle Build Failed - Memory Issues
**Problem**: Build fails with `OutOfMemoryError` or `GC overhead limit exceeded`

**Solution**:
```bash
# Increase Gradle daemon memory
echo "org.gradle.jvmargs=-Xmx4g -XX:+HeapDumpOnOutOfMemoryError" >> ~/.gradle/gradle.properties

# Or pass directly to build
./gradlew assembleDebug -Dorg.gradle.jvmargs="-Xmx4g"

# For very limited memory VPS, disable daemon
./gradlew assembleDebug --no-daemon
```

### Android SDK License Not Accepted
**Problem**: Build fails with license agreement errors

**Solution**:
```bash
# Accept all licenses
yes | sdkmanager --licenses
```

### JAVA_HOME Not Set
**Problem**: Gradle/Android build fails with Java not found

**Solution**:
```bash
# Reload shell or set manually
source ~/.bashrc

# Or set explicitly
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"
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
