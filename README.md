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

### Optional Add-ons
- 🦞 **OpenClaw** - Personal AI assistant via messaging channels (see [OpenClaw Setup](#-openclaw-ai-assistant-optional))

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

## 🔑 Accessing Private GitHub Repositories

To clone and work with private GitHub repositories on your VPS, you need to set up authentication. Here are the recommended methods:

### Method 1: SSH Keys (Recommended)

SSH keys provide secure, password-less authentication for all your GitHub repositories.

#### Step 1: Generate SSH Key

```bash
# Generate a new ED25519 SSH key (recommended)
ssh-keygen -t ed25519 -C "your.email@example.com"

# Or use RSA if ED25519 is not supported
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"
```

When prompted:
- Press Enter to accept the default file location (`~/.ssh/id_ed25519`)
- Enter a passphrase for extra security (optional but recommended)

#### Step 2: Add SSH Key to GitHub

```bash
# Display your public key
cat ~/.ssh/id_ed25519.pub
```

Copy the output and add it to GitHub:
1. Go to [GitHub SSH Settings](https://github.com/settings/keys)
2. Click **New SSH key**
3. Give it a descriptive title (e.g., "VPS Development Server")
4. Paste your public key
5. Click **Add SSH key**

#### Step 3: Test the Connection

```bash
# Test SSH connection to GitHub
ssh -T git@github.com
```

You should see: `Hi username! You've successfully authenticated...`

#### Step 4: Clone Repositories Using SSH

```bash
# Clone using SSH URL (starts with git@github.com:)
git clone git@github.com:username/private-repo.git

# Or update existing repo to use SSH
git remote set-url origin git@github.com:username/private-repo.git
```

### Method 2: GitHub CLI Authentication

The GitHub CLI (`gh`) provides easy authentication with browser-based login.

```bash
# Start authentication
gh auth login

# Follow the prompts:
# 1. Select GitHub.com
# 2. Select SSH as preferred protocol
# 3. Upload your SSH key (or generate a new one)
# 4. Complete browser-based authentication

# Verify authentication
gh auth status

# Clone private repositories
gh repo clone username/private-repo
```

### Method 3: Deploy Keys (For Specific Repositories)

Use deploy keys when you need read-only access to specific repositories (useful for CI/CD or automated deployments).

```bash
# Generate a dedicated key for the specific repo
ssh-keygen -t ed25519 -C "deploy-key-myproject" -f ~/.ssh/deploy_myproject

# Display the public key
cat ~/.ssh/deploy_myproject.pub
```

Add the deploy key to your repository:
1. Go to your repository on GitHub
2. Navigate to **Settings** → **Deploy keys**
3. Click **Add deploy key**
4. Paste the public key and give it a title
5. Check "Allow write access" if needed

Configure SSH to use the deploy key:

```bash
# Add to ~/.ssh/config
cat >> ~/.ssh/config << 'EOF'
Host github-myproject
    HostName github.com
    User git
    IdentityFile ~/.ssh/deploy_myproject
    IdentitiesOnly yes
EOF

# Clone using the custom host alias
git clone git@github-myproject:username/private-repo.git
```

### Method 4: Personal Access Token (PAT)

Use tokens for HTTPS-based authentication (useful for scripts and automation).

#### Create a Token

1. Go to [GitHub Token Settings](https://github.com/settings/tokens)
2. Click **Generate new token (classic)** or **Fine-grained tokens**
3. Select scopes: `repo` (for full repository access)
4. Copy the generated token

#### Configure Git to Use Token

```bash
# Option A: Use credential helper to cache token
git config --global credential.helper store

# Clone a repo and enter token when prompted for password
git clone https://github.com/username/private-repo.git
# Username: your-github-username
# Password: paste-your-token-here

# Option B: Include token in remote URL (less secure, avoid for shared systems)
git clone https://YOUR_TOKEN@github.com/username/private-repo.git
```

> ⚠️ **Security Warning**: Tokens in URLs may appear in logs. Use SSH keys or credential helpers instead for better security.

### Best Practices

1. **Use SSH Keys** - Most secure and convenient for regular development work
2. **Use Deploy Keys** - For automated systems that need access to specific repositories
3. **Use Tokens Sparingly** - Only for scripts that require HTTPS; rotate them regularly
4. **Protect Private Keys** - Never share or commit your private keys (`id_ed25519`, not `.pub`)
5. **Use Passphrases** - Add a passphrase to SSH keys for extra security
6. **Use SSH Agent** - Avoid entering passphrases repeatedly

#### SSH Agent Setup

```bash
# Start SSH agent
eval "$(ssh-agent -s)"

# Add your key (you'll enter passphrase once per session)
ssh-add ~/.ssh/id_ed25519

# Verify loaded keys
ssh-add -l
```

To automatically start SSH agent, add to your `~/.bashrc`:

```bash
# Auto-start SSH agent
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
```

### Troubleshooting

#### "Permission denied (publickey)"

```bash
# Check if SSH agent has your key
ssh-add -l

# If empty, add your key
ssh-add ~/.ssh/id_ed25519

# Verify the key is in GitHub
curl -s https://api.github.com/users/YOUR_USERNAME/keys

# Test with verbose output
ssh -vT git@github.com
```

#### "Host key verification failed"

```bash
# Add GitHub's host key to known hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

#### Multiple GitHub Accounts

If you use multiple GitHub accounts, configure SSH with different hosts:

```bash
# ~/.ssh/config
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
```

Use the appropriate host when cloning:

```bash
git clone git@github-personal:personal-account/repo.git
git clone git@github-work:work-org/repo.git
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

### OpenClaw (Optional Add-on)
```bash
oc          # openclaw
oc-chat     # openclaw chat
oc-status   # Gateway service status
oc-start    # Start Gateway service
oc-stop     # Stop Gateway service
oc-restart  # Restart Gateway service
oc-logs     # View Gateway logs (live)
oc-config   # Edit configuration
oc-check    # Quick status overview
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

## 🦞 OpenClaw AI Assistant (Optional)

OpenClaw is an optional add-on that enables you to interact with AI through messaging platforms (WhatsApp, Telegram, Discord, Slack). It runs as a Gateway service on your VPS.

### Why Use OpenClaw?

- **Message from anywhere**: Chat with your AI assistant via your phone's messaging apps
- **Persistent sessions**: Your conversations continue even when you disconnect
- **Multiple channels**: Support for WhatsApp, Telegram, Discord, and Slack
- **Secure by default**: Loopback binding, pairing mode, and sandbox isolation

### Installation

After running `vps-dev-setup.sh`, install OpenClaw with the optional script:

```bash
# Download and run OpenClaw setup
chmod +x openclaw-setup.sh
./openclaw-setup.sh

# Source bashrc to get aliases
source ~/.bashrc

# Complete onboarding
openclaw onboard
```

> **Note**: OpenClaw requires Node.js v22+. The setup script will upgrade your Node.js if needed (from v20 installed by the main script).

### Quick Start

```bash
# 1. Set your API key (if not done during onboarding)
openclaw config set apiKey YOUR_ANTHROPIC_API_KEY

# 2. Start the Gateway service
oc-start

# 3. Check status
oc-status

# 4. View logs
oc-logs
```

### Gateway Service Management

The Gateway runs as a systemd user service:

```bash
# Start/stop/restart
systemctl --user start openclaw-gateway
systemctl --user stop openclaw-gateway
systemctl --user restart openclaw-gateway

# Check status
systemctl --user status openclaw-gateway

# View logs
journalctl --user -u openclaw-gateway -f

# Or use the aliases:
oc-start / oc-stop / oc-restart / oc-status / oc-logs
```

### Configuration

Configuration is stored at `~/.openclaw/openclaw.json`. Edit with:

```bash
oc-config    # Opens in nano/your editor
```

Default secure settings:
- Gateway bound to `127.0.0.1:18789` (localhost only)
- All messaging channels disabled
- Pairing mode enabled for all channels
- Sandbox mode for non-main sessions

### Enabling Messaging Channels

> ⚠️ **Security Warning**: Only enable channels you need. Each channel requires explicit configuration to prevent unauthorized access.

```bash
# Edit configuration
oc-config

# Find the channel you want to enable and set "enabled": true
# Configure allowFrom lists for authorized contacts
# Restart the gateway
oc-restart
```

For detailed channel setup, see [docs/OPENCLAW.md](docs/OPENCLAW.md) or visit:
- https://docs.openclaw.ai/channels/whatsapp
- https://docs.openclaw.ai/channels/telegram
- https://docs.openclaw.ai/channels/discord
- https://docs.openclaw.ai/channels/slack

### Remote Access

The Gateway binds to localhost only by default. For remote access:

#### Option 1: SSH Tunnel (Recommended)
```bash
# From your local machine
ssh -L 18789:127.0.0.1:18789 user@your-vps-ip

# Gateway is now accessible at localhost:18789 on your machine
```

#### Option 2: Tailscale
```bash
# Install Tailscale on VPS and client device
# Update openclaw.json to allow Tailscale:
# "auth": { "allowTailscale": true }
```

### Directory Structure

```
~/.openclaw/
├── openclaw.json       # Main configuration
├── workspace/          # Agent workspace
└── backups/            # Configuration backups

~/logs/openclaw/
├── openclaw.log        # Application logs
├── gateway.log         # Gateway service logs
├── gateway-error.log   # Gateway error logs
└── audit.log           # Security audit trail
```

### OpenClaw Aliases Reference

```bash
# Commands
oc              # openclaw (main CLI)
oc-chat         # openclaw chat
oc-code         # openclaw code

# Service management
oc-start        # Start Gateway
oc-stop         # Stop Gateway
oc-restart      # Restart Gateway
oc-status       # Check Gateway status
oc-enable       # Enable Gateway on boot
oc-disable      # Disable Gateway on boot

# Logs
oc-logs         # Live Gateway logs
oc-logs-all     # All Gateway logs
oc-logs-error   # Error logs only

# Configuration
oc-config       # Edit configuration
oc-check        # Quick status check

# Navigation
oc-workspace    # Go to workspace directory
```

### Uninstalling OpenClaw

```bash
# Stop and disable the service
oc-stop
systemctl --user disable openclaw-gateway

# Remove the npm package
npm uninstall -g openclaw

# Remove configuration and workspace (optional)
rm -rf ~/.openclaw
rm ~/.config/systemd/user/openclaw-gateway.service

# Remove log files (optional)
rm -rf ~/logs/openclaw

# Remove aliases from .bashrc (manual)
nano ~/.bashrc
# Delete the "OpenClaw Configuration" section
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

### OpenClaw Gateway Won't Start
**Problem**: `oc-start` fails or Gateway service won't start

**Solution**:
```bash
# Check service status for error details
oc-status

# Check logs for specific errors
oc-logs-error

# Verify configuration is valid JSON
openclaw config validate

# Ensure Node.js v22+ is active
node --version
# If not v22+, switch:
nvm use 22

# Restart the service
systemctl --user daemon-reload
oc-restart
```

### OpenClaw Command Not Found
**Problem**: `openclaw: command not found` after installation

**Solution**:
```bash
# Reload NVM and shell
source ~/.nvm/nvm.sh
source ~/.bashrc

# Verify Node.js is using correct version
nvm use 22

# Check if openclaw is in npm global
npm list -g openclaw

# If not found, reinstall
npm install -g openclaw@latest
```

### OpenClaw Gateway Port Already in Use
**Problem**: Gateway fails with "port 18789 already in use"

**Solution**:
```bash
# Find process using the port
sudo lsof -i :18789

# Kill the process
sudo kill -9 <PID>

# Or change the port in configuration
oc-config
# Change "port": 18789 to another port
oc-restart
```

### OpenClaw Sandbox Mode Fails
**Problem**: Sandbox mode errors or Docker-related failures

**Solution**:
```bash
# Verify Docker is running
docker info

# If Docker permission denied, add user to docker group
sudo usermod -aG docker $USER
# Log out and back in

# Check Docker is accessible
docker run hello-world

# Restart OpenClaw Gateway
oc-restart
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
