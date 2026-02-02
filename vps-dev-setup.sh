#!/bin/bash

################################################################################
# VPS Development Environment Setup Script
# Target: Ubuntu 24.04 LTS
# Purpose: Complete development environment for Claude Code + Multi-stack development
# Date: February 2026
################################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    log_error "Please do not run this script as root. Run as regular user with sudo privileges."
    exit 1
fi

log_info "Starting VPS Development Environment Setup..."
log_info "Target System: Ubuntu 24.04 LTS"
echo ""

################################################################################
# 1. SYSTEM UPDATE & ESSENTIAL PACKAGES
################################################################################

log_info "Step 1: Updating system and installing essential packages..."

sudo apt update
sudo apt upgrade -y

# Essential build tools and dependencies
sudo apt install -y \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    git \
    tmux \
    vim \
    nano \
    htop \
    btop \
    ncdu \
    tree \
    jq \
    zip \
    unzip \
    p7zip-full \
    net-tools \
    dnsutils \
    iputils-ping \
    traceroute \
    openssh-server \
    fail2ban \
    ufw \
    certbot

log_success "System updated and essential packages installed"

################################################################################
# 2. GIT CONFIGURATION
################################################################################

log_info "Step 2: Configuring Git..."

# Check if git is already configured
if [ -z "$(git config --global user.name)" ]; then
    log_warning "Git user.name not configured. Please set it manually:"
    log_warning "  git config --global user.name 'Your Name'"
fi

if [ -z "$(git config --global user.email)" ]; then
    log_warning "Git user.email not configured. Please set it manually:"
    log_warning "  git config --global user.email 'your.email@example.com'"
fi

# Set useful git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Modern git configurations
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor vim

log_success "Git configured with useful aliases"

################################################################################
# 3. TMUX CONFIGURATION
################################################################################

log_info "Step 3: Configuring tmux..."

# Create tmux config with sensible defaults
cat > ~/.tmux.conf << 'EOF'
# Tmux configuration for development

# Set prefix to Ctrl-a (easier than Ctrl-b)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Enable mouse support
set -g mouse on

# Start window numbering at 1
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when one is closed
set -g renumber-windows on

# Increase scrollback buffer size
set -g history-limit 50000

# Display tmux messages for 4 seconds
set -g display-time 4000

# Refresh status line every 5 seconds
set -g status-interval 5

# Enable focus events
set -g focus-events on

# Aggressive resize
setw -g aggressive-resize on

# Better colors
set -g default-terminal "screen-256color"

# Status bar customization
set -g status-style bg=black,fg=white
set -g status-left '[#S] '
set -g status-right '#H | %Y-%m-%d %H:%M'

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Easy pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
EOF

log_success "Tmux configured with development-friendly settings"

################################################################################
# 4. DOCKER & DOCKER COMPOSE
################################################################################

log_info "Step 4: Installing Docker and Docker Compose..."

# Remove old Docker installations
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo apt remove -y $pkg 2>/dev/null || true
done

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group
sudo usermod -aG docker $USER

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

log_success "Docker and Docker Compose installed"
log_warning "You need to log out and log back in for Docker group membership to take effect"

################################################################################
# 5. NVM, NODE.JS & NPM ECOSYSTEM
################################################################################

log_info "Step 5: Installing NVM and Node.js..."

# Install NVM
export NVM_DIR="$HOME/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Load NVM
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Add NVM to shell profile if not already there
if ! grep -q 'NVM_DIR' ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
fi

# Install Node.js v20.19.4
nvm install 20.19.4
nvm use 20.19.4
nvm alias default 20.19.4

# Update npm to latest
npm install -g npm@latest

# Install pnpm
npm install -g pnpm

# Install useful global packages
npm install -g \
    yarn \
    pm2 \
    nodemon \
    typescript \
    ts-node \
    @nestjs/cli \
    eslint \
    prettier

log_success "NVM, Node.js v20.19.4, npm, pnpm, and essential packages installed"

################################################################################
# 6. .NET 8 SDK & RUNTIME
################################################################################

log_info "Step 6: Installing .NET 8 SDK and Runtime..."

# Add Microsoft package repository
wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

sudo apt update
sudo apt install -y dotnet-sdk-8.0 dotnet-runtime-8.0 aspnetcore-runtime-8.0

log_success ".NET 8 SDK and Runtime installed"

################################################################################
# 7. PYTHON ENVIRONMENT
################################################################################

log_info "Step 7: Setting up Python environment..."

# Install Python 3 and essential tools
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python-is-python3

# Upgrade pip
python3 -m pip install --user --upgrade pip

# Install common Python development tools
python3 -m pip install --user \
    pipenv \
    poetry \
    virtualenv \
    ipython \
    jupyter \
    black \
    flake8 \
    pylint \
    mypy \
    pytest \
    requests \
    python-dotenv

log_success "Python environment configured with essential tools"

################################################################################
# 8. PHP & COMPOSER
################################################################################

log_info "Step 8: Installing PHP and Composer..."

# Install PHP 8.3 and extensions
sudo apt install -y \
    php8.3 \
    php8.3-cli \
    php8.3-fpm \
    php8.3-common \
    php8.3-mysql \
    php8.3-pgsql \
    php8.3-sqlite3 \
    php8.3-zip \
    php8.3-gd \
    php8.3-mbstring \
    php8.3-curl \
    php8.3-xml \
    php8.3-bcmath \
    php8.3-intl \
    php8.3-redis \
    composer

log_success "PHP 8.3 and Composer installed"

################################################################################
# 9. DATABASE CLIENTS
################################################################################

log_info "Step 9: Installing database clients..."

# MySQL client
sudo apt install -y mysql-client

# PostgreSQL client
sudo apt install -y postgresql-client

# Redis client
sudo apt install -y redis-tools

# SQLite
sudo apt install -y sqlite3

# MongoDB Shell (mongosh)
log_info "Installing MongoDB Shell (mongosh)..."

# Add MongoDB GPG key (convert to binary format for modern apt)
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg

# Get Ubuntu codename and check if MongoDB supports it, fallback to jammy if not
UBUNTU_CODENAME=$(lsb_release -cs)
# MongoDB 7.0 supports: focal (20.04), jammy (22.04), noble (24.04)
case "$UBUNTU_CODENAME" in
    focal|jammy|noble)
        MONGODB_CODENAME="$UBUNTU_CODENAME"
        ;;
    *)
        log_warning "Ubuntu $UBUNTU_CODENAME not officially supported by MongoDB 7.0, using jammy repository"
        MONGODB_CODENAME="jammy"
        ;;
esac

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu ${MONGODB_CODENAME}/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list > /dev/null
sudo apt update
sudo apt install -y mongodb-mongosh

log_success "Database clients installed"

################################################################################
# 10. CLAUDE CODE CLI
################################################################################

log_info "Step 10: Installing Claude Code CLI..."

# Install Claude Code
curl -fsSL https://claude.ai/cli/install.sh | sh

# Add to PATH if not already there
if ! grep -q '.claude/bin' ~/.bashrc; then
    echo 'export PATH="$HOME/.claude/bin:$PATH"' >> ~/.bashrc
fi

log_success "Claude Code CLI installed"

################################################################################
# 11. ANDROID DEVELOPMENT ENVIRONMENT
################################################################################

log_info "Step 11: Installing Android development environment..."

# Install OpenJDK 17 (required for Android development)
sudo apt install -y openjdk-17-jdk openjdk-17-jre

# Set JAVA_HOME
JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-amd64"
if ! grep -q 'JAVA_HOME' ~/.bashrc; then
    cat >> ~/.bashrc << EOF

# Java Configuration
export JAVA_HOME="${JAVA_HOME_PATH}"
export PATH="\$JAVA_HOME/bin:\$PATH"
EOF
fi
export JAVA_HOME="${JAVA_HOME_PATH}"
export PATH="$JAVA_HOME/bin:$PATH"

# Create Android SDK directory
ANDROID_HOME="$HOME/Android/Sdk"
mkdir -p "$ANDROID_HOME/cmdline-tools"

# Download Android command-line tools
log_info "Downloading Android command-line tools..."
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
CMDLINE_TOOLS_ZIP="/tmp/commandlinetools.zip"
curl -Lo "$CMDLINE_TOOLS_ZIP" "$CMDLINE_TOOLS_URL"

# Extract to the correct location
unzip -q "$CMDLINE_TOOLS_ZIP" -d "/tmp/cmdline-tools-temp"
mv /tmp/cmdline-tools-temp/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
rm -rf /tmp/cmdline-tools-temp "$CMDLINE_TOOLS_ZIP"

# Add Android SDK to PATH
if ! grep -q 'ANDROID_HOME' ~/.bashrc; then
    cat >> ~/.bashrc << EOF

# Android SDK Configuration
export ANDROID_HOME="\$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="\$ANDROID_HOME"
export PATH="\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/build-tools/35.0.0:\$PATH"
EOF
fi

# Export for current session
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# Accept licenses
log_info "Accepting Android SDK licenses..."
yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses > /dev/null 2>&1 || true

# Install essential SDK packages
log_info "Installing Android SDK packages (this may take a while)..."
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --install \
    "platform-tools" \
    "build-tools;35.0.0" \
    "platforms;android-35" \
    "platforms;android-34" \
    "emulator" \
    "extras;android;m2repository" \
    "extras;google;m2repository"

# Install Gradle
log_info "Installing Gradle..."
GRADLE_VERSION="8.12"
GRADLE_ZIP="/tmp/gradle.zip"
curl -Lo "$GRADLE_ZIP" "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
sudo unzip -q "$GRADLE_ZIP" -d /opt
sudo ln -sf "/opt/gradle-${GRADLE_VERSION}/bin/gradle" /usr/local/bin/gradle
rm "$GRADLE_ZIP"

log_success "Android development environment installed"
log_info "  - OpenJDK 17"
log_info "  - Android SDK (platforms 34, 35)"
log_info "  - Android Build Tools 35.0.0"
log_info "  - Android Platform Tools"
log_info "  - Gradle ${GRADLE_VERSION}"

################################################################################
# 12. ADDITIONAL DEVELOPMENT TOOLS
################################################################################

log_info "Step 12: Installing additional development tools..."

# Install GitHub CLI
(type -p wget >/dev/null || (sudo apt update && sudo apt install -y wget)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubkey.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install -y gh

# Install lazygit (better git UI)
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz

# Install fd (better find)
sudo apt install -y fd-find
sudo ln -sf $(which fdfind) /usr/local/bin/fd 2>/dev/null || true

# Install ripgrep (better grep)
sudo apt install -y ripgrep

# Install bat (better cat)
sudo apt install -y bat
sudo ln -sf /usr/bin/batcat /usr/local/bin/bat 2>/dev/null || true

# Install exa (better ls)
sudo apt install -y exa

log_success "Additional development tools installed"

################################################################################
# 13. BASH ALIASES & ENVIRONMENT
################################################################################

log_info "Step 13: Setting up bash aliases and environment..."

# Add useful aliases to .bashrc
cat >> ~/.bashrc << 'EOF'

# ============================================================================
# Development Environment Aliases
# ============================================================================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Listing (using exa if available, fallback to ls)
if command -v exa &> /dev/null; then
    alias ls='exa --icons'
    alias ll='exa -lah --icons --git'
    alias la='exa -a --icons'
    alias lt='exa --tree --level=2 --icons'
else
    alias ll='ls -alh'
    alias la='ls -A'
fi

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'

# Docker shortcuts
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dprune='docker system prune -af'

# Node/NPM shortcuts
alias ni='npm install'
alias ns='npm start'
alias nt='npm test'
alias nr='npm run'
alias pn='pnpm'

# System monitoring
alias ports='netstat -tulanp'
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'
alias usage='du -h -d1'

# Tmux shortcuts
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias tn='tmux new -s'

# Claude Code shortcut
alias cc='claude-code'

# Quick edit configs
alias bashrc='vim ~/.bashrc'
alias tmuxconf='vim ~/.tmux.conf'

# Reload bash config
alias reload='source ~/.bashrc'

EOF

log_success "Bash aliases and environment configured"

################################################################################
# 14. SECURITY SETUP
################################################################################

log_info "Step 14: Configuring basic security..."

# Configure UFW firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw --force enable

# Configure fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

log_success "Basic security configured (UFW + fail2ban)"

################################################################################
# 15. WORKSPACE SETUP
################################################################################

log_info "Step 15: Creating workspace directories..."

# Create standard workspace structure
mkdir -p ~/projects/{web,api,mobile,automation,experiments}
mkdir -p ~/backups
mkdir -p ~/scripts
mkdir -p ~/logs

log_success "Workspace directories created"

################################################################################
# 16. SYSTEM INFO & FINAL STEPS
################################################################################

echo ""
echo "============================================================================"
log_success "VPS Development Environment Setup Complete!"
echo "============================================================================"
echo ""

# Display installed versions
log_info "Installed Software Versions:"
echo ""
echo "  System:"
echo "    OS:           $(lsb_release -ds)"
echo "    Kernel:       $(uname -r)"
echo ""
echo "  Core Tools:"
echo "    Git:          $(git --version | cut -d' ' -f3)"
echo "    Tmux:         $(tmux -V | cut -d' ' -f2)"
echo "    Docker:       $(docker --version | cut -d' ' -f3 | tr -d ',')"
echo ""
echo "  Languages & Runtimes:"
# Check if NVM is loaded
if command -v node &> /dev/null; then
    echo "    Node.js:      $(node --version)"
    echo "    npm:          $(npm --version)"
    echo "    pnpm:         $(pnpm --version)"
else
    echo "    Node.js:      Installing (reload shell to use)"
fi

if command -v dotnet &> /dev/null; then
    echo "    .NET:         $(dotnet --version)"
fi

echo "    Python:       $(python3 --version | cut -d' ' -f2)"
echo "    PHP:          $(php --version | head -n1 | cut -d' ' -f2)"
echo ""
echo "  Android Development:"
echo "    Java:         $(java --version 2>&1 | head -n1)"
if command -v gradle &> /dev/null; then
    echo "    Gradle:       $(gradle --version 2>&1 | grep "Gradle" | cut -d' ' -f2)"
fi
if [ -d "$ANDROID_HOME" ]; then
    echo "    Android SDK:  $ANDROID_HOME"
    echo "    Build Tools:  35.0.0"
    echo "    Platforms:    android-34, android-35"
fi
echo ""

echo "============================================================================"
log_warning "IMPORTANT: Next Steps"
echo "============================================================================"
echo ""
echo "  1. Log out and log back in to apply Docker group membership"
echo ""
echo "  2. Configure Git credentials:"
echo "     git config --global user.name 'Your Name'"
echo "     git config --global user.email 'your.email@example.com'"
echo ""
echo "  3. Set up SSH keys for GitHub:"
echo "     ssh-keygen -t ed25519 -C 'your.email@example.com'"
echo "     cat ~/.ssh/id_ed25519.pub"
echo "     # Add the key to GitHub: https://github.com/settings/keys"
echo ""
echo "  4. Authenticate Claude Code:"
echo "     claude-code auth"
echo ""
echo "  5. Start a tmux session:"
echo "     tmux new -s work"
echo ""
echo "  6. Clone your repositories:"
echo "     cd ~/projects/web"
echo "     git clone <your-repo-url>"
echo ""
echo "============================================================================"
log_info "Workspace Locations:"
echo "============================================================================"
echo ""
echo "  ~/projects/web              - Web application projects"
echo "  ~/projects/api              - API/Backend projects"
echo "  ~/projects/mobile           - Mobile app projects"
echo "  ~/projects/automation       - Automation scripts"
echo "  ~/projects/experiments      - Testing & experiments"
echo "  ~/backups                   - Local backups"
echo "  ~/scripts                   - Utility scripts"
echo "  ~/logs                      - Application logs"
echo ""
echo "============================================================================"
log_info "Useful Commands:"
echo "============================================================================"
echo ""
echo "  System:"
echo "    htop / btop               - System monitor"
echo "    ncdu                      - Disk usage analyzer"
echo "    duf                       - Disk usage (modern)"
echo ""
echo "  Docker:"
echo "    dc up -d                  - Start services"
echo "    dc logs -f                - Follow logs"
echo "    dprune                    - Clean up Docker"
echo ""
echo "  Tmux:"
echo "    Ctrl+A then |             - Split vertically"
echo "    Ctrl+A then -             - Split horizontally"
echo "    Ctrl+A then h/j/k/l       - Navigate panes"
echo "    Ctrl+A then d             - Detach session"
echo "    ta <session-name>         - Attach to session"
echo ""
echo "  Git:"
echo "    lazygit                   - Beautiful Git UI"
echo "    gh                        - GitHub CLI"
echo ""
echo "============================================================================"

log_success "Setup script completed successfully!"
echo ""
log_info "Run 'source ~/.bashrc' to apply aliases, or log out and log back in."
echo ""
