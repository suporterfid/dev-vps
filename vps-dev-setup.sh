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

################################################################################
# LOGGING SETUP
################################################################################

# Setup log file with timestamp
LOG_DIR="$HOME/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/vps-setup-$(date +%Y%m%d-%H%M%S).log"
touch "$LOG_FILE"

# Log functions - write to both console and file
log_info() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}[INFO]${NC} $1"
    echo "[$timestamp] [INFO] $1" >> "$LOG_FILE"
}

log_success() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "[$timestamp] [SUCCESS] $1" >> "$LOG_FILE"
}

log_warning() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "[$timestamp] [WARNING] $1" >> "$LOG_FILE"
}

log_error() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[$timestamp] [ERROR] $1" >> "$LOG_FILE"
}

log_step() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}[STEP]${NC} $1"
    echo -e "${BLUE}========================================${NC}"
    echo "" >> "$LOG_FILE"
    echo "[$timestamp] [STEP] ======================================" >> "$LOG_FILE"
    echo "[$timestamp] [STEP] $1" >> "$LOG_FILE"
    echo "[$timestamp] [STEP] ======================================" >> "$LOG_FILE"
}

log_skip() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${YELLOW}[SKIP]${NC} $1 - already completed"
    echo "[$timestamp] [SKIP] $1 - already completed" >> "$LOG_FILE"
}

################################################################################
# VERIFICATION FUNCTIONS
################################################################################

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if a package is installed
package_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Check if multiple packages are installed
packages_installed() {
    local all_installed=true
    for pkg in "$@"; do
        if ! package_installed "$pkg"; then
            all_installed=false
            break
        fi
    done
    $all_installed
}

# Check if a file exists
file_exists() {
    [ -f "$1" ]
}

# Check if a directory exists
dir_exists() {
    [ -d "$1" ]
}

# Check if a service is running
service_running() {
    systemctl is-active --quiet "$1"
}

# Check if a grep pattern exists in a file
pattern_in_file() {
    local pattern="$1"
    local file="$2"
    grep -q "$pattern" "$file" 2>/dev/null
}

# Check if user is in a group
user_in_group() {
    groups "$USER" 2>/dev/null | grep -q "\b$1\b"
}

# Check node version matches
node_version_matches() {
    local expected="$1"
    if command_exists node; then
        local current=$(node --version 2>/dev/null | sed 's/v//')
        [ "$current" = "$expected" ]
    else
        return 1
    fi
}

################################################################################
# ERROR HANDLING
################################################################################

# Error handler
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_error "Error on line $line_number. Exit code: $exit_code"
    log_error "Check log file for details: $LOG_FILE"
    exit $exit_code
}

# Set error trap
trap 'handle_error $LINENO' ERR

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    log_error "Please do not run this script as root. Run as regular user with sudo privileges."
    exit 1
fi

log_info "Starting VPS Development Environment Setup..."
log_info "Target System: Ubuntu 24.04 LTS"
log_info "Log file: $LOG_FILE"
echo ""

################################################################################
# 1. SYSTEM UPDATE & ESSENTIAL PACKAGES
################################################################################

log_step "Step 1: Updating system and installing essential packages..."

# Define essential packages
ESSENTIAL_PACKAGES=(
    build-essential software-properties-common apt-transport-https ca-certificates
    curl wget gnupg lsb-release git tmux vim nano htop btop ncdu tree jq
    zip unzip p7zip-full net-tools dnsutils iputils-ping traceroute
    openssh-server fail2ban ufw certbot
)

# Check if essential packages are already installed
MISSING_PACKAGES=()
for pkg in "${ESSENTIAL_PACKAGES[@]}"; do
    if ! package_installed "$pkg"; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    log_skip "Essential packages"
else
    log_info "Installing ${#MISSING_PACKAGES[@]} missing packages..."
    
    sudo apt update 2>&1 | tee -a "$LOG_FILE"
    sudo apt upgrade -y 2>&1 | tee -a "$LOG_FILE"
    
    # Install all essential packages
    sudo apt install -y "${ESSENTIAL_PACKAGES[@]}" 2>&1 | tee -a "$LOG_FILE"
    
    log_success "System updated and essential packages installed"
fi

################################################################################
# 2. GIT CONFIGURATION
################################################################################

log_step "Step 2: Configuring Git..."

# Check if git aliases are already configured
if git config --global alias.co &> /dev/null && \
   git config --global alias.br &> /dev/null && \
   git config --global alias.lg &> /dev/null; then
    log_skip "Git aliases"
else
    log_info "Configuring Git aliases and settings..."
    
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
    git config --global alias.co checkout 2>&1 | tee -a "$LOG_FILE"
    git config --global alias.br branch 2>&1 | tee -a "$LOG_FILE"
    git config --global alias.ci commit 2>&1 | tee -a "$LOG_FILE"
    git config --global alias.st status 2>&1 | tee -a "$LOG_FILE"
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit" 2>&1 | tee -a "$LOG_FILE"

    # Modern git configurations
    git config --global init.defaultBranch main 2>&1 | tee -a "$LOG_FILE"
    git config --global pull.rebase false 2>&1 | tee -a "$LOG_FILE"
    git config --global core.editor vim 2>&1 | tee -a "$LOG_FILE"

    log_success "Git configured with useful aliases"
fi

################################################################################
# 3. TMUX CONFIGURATION
################################################################################

log_step "Step 3: Configuring tmux..."

# Check if tmux config already exists with our settings
if file_exists "$HOME/.tmux.conf" && pattern_in_file "prefix C-a" "$HOME/.tmux.conf"; then
    log_skip "Tmux configuration"
else
    log_info "Creating tmux configuration..."
    
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
fi

################################################################################
# 4. DOCKER & DOCKER COMPOSE
################################################################################

log_step "Step 4: Installing Docker and Docker Compose..."

# Check if Docker is already installed and running
if command_exists docker && service_running docker; then
    log_skip "Docker installation"
    # Still check if user is in docker group
    if ! user_in_group docker; then
        log_info "Adding user to docker group..."
        sudo usermod -aG docker $USER 2>&1 | tee -a "$LOG_FILE"
        log_warning "You need to log out and log back in for Docker group membership to take effect"
    fi
else
    log_info "Installing Docker and Docker Compose..."
    
    # Remove old Docker installations
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
        sudo apt remove -y $pkg 2>/dev/null || true
    done

    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings 2>&1 | tee -a "$LOG_FILE"
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc 2>&1 | tee -a "$LOG_FILE"
    sudo chmod a+r /etc/apt/keyrings/docker.asc 2>&1 | tee -a "$LOG_FILE"

    # Add Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    sudo apt update 2>&1 | tee -a "$LOG_FILE"
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>&1 | tee -a "$LOG_FILE"

    # Add current user to docker group
    sudo usermod -aG docker $USER 2>&1 | tee -a "$LOG_FILE"

    # Enable and start Docker
    sudo systemctl enable docker 2>&1 | tee -a "$LOG_FILE"
    sudo systemctl start docker 2>&1 | tee -a "$LOG_FILE"

    log_success "Docker and Docker Compose installed"
    log_warning "You need to log out and log back in for Docker group membership to take effect"
fi

################################################################################
# 5. NVM, NODE.JS & NPM ECOSYSTEM
################################################################################

log_step "Step 5: Installing NVM and Node.js..."

NODE_VERSION="20.19.4"
export NVM_DIR="$HOME/.nvm"

# Check if NVM is already installed
if dir_exists "$NVM_DIR" && file_exists "$NVM_DIR/nvm.sh"; then
    log_skip "NVM installation"
    # Load NVM
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
    log_info "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash 2>&1 | tee -a "$LOG_FILE"
    
    # Load NVM
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Add NVM to shell profile if not already there
if ! pattern_in_file 'NVM_DIR' ~/.bashrc; then
    log_info "Adding NVM to .bashrc..."
    cat >> ~/.bashrc << 'EOF'

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
fi

# Load NVM if available
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Check if Node.js is already installed with correct version
if command_exists nvm && nvm list "$NODE_VERSION" &> /dev/null; then
    log_skip "Node.js v$NODE_VERSION"
    nvm use "$NODE_VERSION" > /dev/null 2>&1 || true
else
    log_info "Installing Node.js v$NODE_VERSION..."
    nvm install "$NODE_VERSION" 2>&1 | tee -a "$LOG_FILE"
    nvm use "$NODE_VERSION" 2>&1 | tee -a "$LOG_FILE"
    nvm alias default "$NODE_VERSION" 2>&1 | tee -a "$LOG_FILE"
fi

# Update npm to latest
if command_exists npm; then
    log_info "Updating npm to latest..."
    npm install -g npm@latest 2>&1 | tee -a "$LOG_FILE"
fi

# Check if global packages are installed
GLOBAL_NPM_PACKAGES=(pnpm yarn pm2 nodemon typescript ts-node @nestjs/cli eslint prettier)
MISSING_NPM_PACKAGES=()

for pkg in "${GLOBAL_NPM_PACKAGES[@]}"; do
    if ! npm list -g "$pkg" &> /dev/null; then
        MISSING_NPM_PACKAGES+=("$pkg")
    fi
done

if [ ${#MISSING_NPM_PACKAGES[@]} -eq 0 ]; then
    log_skip "Global npm packages"
else
    log_info "Installing ${#MISSING_NPM_PACKAGES[@]} npm packages..."
    npm install -g "${MISSING_NPM_PACKAGES[@]}" 2>&1 | tee -a "$LOG_FILE"
fi

log_success "NVM, Node.js v$NODE_VERSION, npm, pnpm, and essential packages installed"

################################################################################
# 6. .NET 8 SDK & RUNTIME
################################################################################

log_step "Step 6: Installing .NET 8 SDK and Runtime..."

# Check if .NET 8 SDK is already installed
if command_exists dotnet && dotnet --list-sdks 2>/dev/null | grep -q "^8\."; then
    log_skip ".NET 8 SDK"
else
    log_info "Installing .NET 8 SDK and Runtime..."
    
    # Add Microsoft package repository if not already added
    if ! file_exists /etc/apt/sources.list.d/microsoft-prod.list; then
        wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb 2>&1 | tee -a "$LOG_FILE"
        sudo dpkg -i packages-microsoft-prod.deb 2>&1 | tee -a "$LOG_FILE"
        rm packages-microsoft-prod.deb
        sudo apt update 2>&1 | tee -a "$LOG_FILE"
    fi

    sudo apt install -y dotnet-sdk-8.0 dotnet-runtime-8.0 aspnetcore-runtime-8.0 2>&1 | tee -a "$LOG_FILE"

    log_success ".NET 8 SDK and Runtime installed"
fi

################################################################################
# 7. PYTHON ENVIRONMENT
################################################################################

log_step "Step 7: Setting up Python environment..."

# Check if Python packages are already installed
PYTHON_APT_PACKAGES=(python3 python3-pip python3-venv python3-dev python-is-python3)
PYTHON_MISSING=()

for pkg in "${PYTHON_APT_PACKAGES[@]}"; do
    if ! package_installed "$pkg"; then
        PYTHON_MISSING+=("$pkg")
    fi
done

if [ ${#PYTHON_MISSING[@]} -eq 0 ]; then
    log_skip "Python system packages"
else
    log_info "Installing Python system packages..."
    sudo apt install -y "${PYTHON_APT_PACKAGES[@]}" 2>&1 | tee -a "$LOG_FILE"
fi

# Upgrade pip
log_info "Upgrading pip..."
python3 -m pip install --user --upgrade pip 2>&1 | tee -a "$LOG_FILE" || true

# Check if Python dev tools are installed
PYTHON_PIP_PACKAGES=(pipenv poetry virtualenv ipython jupyter black flake8 pylint mypy pytest requests python-dotenv)
PYTHON_PIP_MISSING=()

for pkg in "${PYTHON_PIP_PACKAGES[@]}"; do
    if ! python3 -m pip show "$pkg" &> /dev/null; then
        PYTHON_PIP_MISSING+=("$pkg")
    fi
done

if [ ${#PYTHON_PIP_MISSING[@]} -eq 0 ]; then
    log_skip "Python pip packages"
else
    log_info "Installing ${#PYTHON_PIP_MISSING[@]} Python packages..."
    python3 -m pip install --user "${PYTHON_PIP_MISSING[@]}" 2>&1 | tee -a "$LOG_FILE"
fi

log_success "Python environment configured with essential tools"

################################################################################
# 8. PHP & COMPOSER
################################################################################

log_step "Step 8: Installing PHP and Composer..."

# Check if PHP 8.3 and extensions are already installed
PHP_PACKAGES=(
    php8.3 php8.3-cli php8.3-fpm php8.3-common php8.3-mysql php8.3-pgsql
    php8.3-sqlite3 php8.3-zip php8.3-gd php8.3-mbstring php8.3-curl
    php8.3-xml php8.3-bcmath php8.3-intl php8.3-redis composer
)
PHP_MISSING=()

for pkg in "${PHP_PACKAGES[@]}"; do
    if ! package_installed "$pkg"; then
        PHP_MISSING+=("$pkg")
    fi
done

if [ ${#PHP_MISSING[@]} -eq 0 ]; then
    log_skip "PHP 8.3 and Composer"
else
    log_info "Installing ${#PHP_MISSING[@]} PHP packages..."
    sudo apt install -y "${PHP_PACKAGES[@]}" 2>&1 | tee -a "$LOG_FILE"
    log_success "PHP 8.3 and Composer installed"
fi

################################################################################
# 9. DATABASE CLIENTS
################################################################################

log_step "Step 9: Installing database clients..."

# Check and install MySQL client
if package_installed mysql-client; then
    log_skip "MySQL client"
else
    log_info "Installing MySQL client..."
    sudo apt install -y mysql-client 2>&1 | tee -a "$LOG_FILE"
fi

# Check and install PostgreSQL client
if package_installed postgresql-client; then
    log_skip "PostgreSQL client"
else
    log_info "Installing PostgreSQL client..."
    sudo apt install -y postgresql-client 2>&1 | tee -a "$LOG_FILE"
fi

# Check and install Redis tools
if package_installed redis-tools; then
    log_skip "Redis tools"
else
    log_info "Installing Redis tools..."
    sudo apt install -y redis-tools 2>&1 | tee -a "$LOG_FILE"
fi

# Check and install SQLite
if package_installed sqlite3; then
    log_skip "SQLite"
else
    log_info "Installing SQLite..."
    sudo apt install -y sqlite3 2>&1 | tee -a "$LOG_FILE"
fi

# MongoDB Shell (mongosh)
if command_exists mongosh; then
    log_skip "MongoDB Shell"
else
    log_info "Installing MongoDB Shell (mongosh)..."

    # Add MongoDB GPG key (convert to binary format for modern apt)
    if ! file_exists /usr/share/keyrings/mongodb-server-7.0.gpg; then
        curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg 2>&1 | tee -a "$LOG_FILE"
    fi

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

    if ! file_exists /etc/apt/sources.list.d/mongodb-org-7.0.list; then
        echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu ${MONGODB_CODENAME}/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list > /dev/null
        sudo apt update 2>&1 | tee -a "$LOG_FILE"
    fi
    
    sudo apt install -y mongodb-mongosh 2>&1 | tee -a "$LOG_FILE"
fi

log_success "Database clients installed"

################################################################################
# 10. CLAUDE CODE CLI
################################################################################

log_step "Step 10: Installing Claude Code CLI..."

# Check if Claude Code is already installed
if command_exists claude-code || file_exists "$HOME/.claude/bin/claude-code"; then
    log_skip "Claude Code CLI"
else
    log_info "Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/cli/install.sh | sh 2>&1 | tee -a "$LOG_FILE"
    log_success "Claude Code CLI installed"
fi

# Add to PATH if not already there
if ! pattern_in_file '.claude/bin' ~/.bashrc; then
    log_info "Adding Claude Code to PATH..."
    echo 'export PATH="$HOME/.claude/bin:$PATH"' >> ~/.bashrc
fi

################################################################################
# 11. AI CLI TOOLS
################################################################################

log_step "Step 11: Installing AI CLI Tools..."

# Install Shell-GPT (sgpt) - Simple CLI assistant
if python3 -m pip show shell-gpt &> /dev/null; then
    log_skip "Shell-GPT"
else
    log_info "Installing Shell-GPT..."
    python3 -m pip install --user shell-gpt 2>&1 | tee -a "$LOG_FILE"
fi

# Install Aider - AI pair programming
if python3 -m pip show aider-chat &> /dev/null; then
    log_skip "Aider"
else
    log_info "Installing Aider..."
    python3 -m pip install --user aider-chat 2>&1 | tee -a "$LOG_FILE"
fi

# Install Ollama - Local LLM runtime
if command_exists ollama; then
    log_skip "Ollama"
else
    log_info "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh 2>&1 | tee -a "$LOG_FILE"
fi

# Install GitHub Copilot CLI extension
if command_exists gh; then
    if gh extension list 2>/dev/null | grep -q "copilot"; then
        log_skip "GitHub Copilot CLI extension"
    else
        log_info "Installing GitHub Copilot CLI extension..."
        gh extension install github/gh-copilot 2>&1 | tee -a "$LOG_FILE" || log_warning "GitHub Copilot CLI extension installation failed (may require authentication)"
    fi
else
    log_warning "GitHub CLI not found, skipping GitHub Copilot CLI extension"
fi

# Install Codex CLI (OpenAI)
if npm list -g @openai/codex &> /dev/null; then
    log_skip "Codex CLI"
else
    log_info "Installing Codex CLI (OpenAI)..."
    npm install -g @openai/codex 2>&1 | tee -a "$LOG_FILE" || log_warning "Codex CLI not available, may need manual installation"
fi

# Install Gemini CLI (Google)
if npm list -g @google/gemini-cli &> /dev/null; then
    log_skip "Gemini CLI"
else
    log_info "Installing Gemini CLI..."
    npm install -g @google/gemini-cli 2>&1 | tee -a "$LOG_FILE" || log_warning "Gemini CLI not available in npm, install manually: https://github.com/google-gemini/gemini-cli"
fi

# Install OpenCode (if available)
if npm list -g @anthropic-ai/opencode &> /dev/null || npm list -g opencode-ai &> /dev/null; then
    log_skip "OpenCode"
else
    log_info "Installing OpenCode..."
    npm install -g @anthropic-ai/opencode 2>&1 | tee -a "$LOG_FILE" || npm install -g opencode-ai 2>&1 | tee -a "$LOG_FILE" || log_warning "OpenCode package not found, skipping"
fi

# Install Qodo Command (AI Agent Framework)
if npm list -g qodo &> /dev/null || python3 -m pip show qodo-gen &> /dev/null; then
    log_skip "Qodo"
else
    log_info "Installing Qodo..."
    npm install -g qodo 2>&1 | tee -a "$LOG_FILE" || python3 -m pip install --user qodo-gen 2>&1 | tee -a "$LOG_FILE" || log_warning "Qodo not found in package managers"
fi

# Add Python user bin to PATH if not already there
if ! pattern_in_file 'local/bin' ~/.bashrc; then
    log_info "Adding Python user bin to PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

log_success "AI CLI Tools installed"
log_info "  - Shell-GPT (sgpt) - Simple CLI assistant"
log_info "  - Aider - AI pair programming"
log_info "  - Ollama - Local LLM runtime"
log_info "  - GitHub Copilot CLI (gh copilot)"
log_info "  - Codex CLI (OpenAI)"

################################################################################
# 12. ANDROID DEVELOPMENT ENVIRONMENT
################################################################################

log_step "Step 12: Installing Android development environment..."

# Install OpenJDK 17 (required for Android development)
if package_installed openjdk-17-jdk; then
    log_skip "OpenJDK 17"
else
    log_info "Installing OpenJDK 17..."
    sudo apt install -y openjdk-17-jdk openjdk-17-jre 2>&1 | tee -a "$LOG_FILE"
fi

# Set JAVA_HOME
JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-amd64"
if ! pattern_in_file 'JAVA_HOME' ~/.bashrc; then
    log_info "Adding JAVA_HOME to .bashrc..."
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

# Check if Android SDK is already installed
if dir_exists "$ANDROID_HOME/cmdline-tools/latest/bin" && file_exists "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"; then
    log_skip "Android SDK command-line tools"
else
    log_info "Installing Android SDK..."
    mkdir -p "$ANDROID_HOME/cmdline-tools"

    # Download Android command-line tools
    log_info "Downloading Android command-line tools..."
    CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
    CMDLINE_TOOLS_ZIP="/tmp/commandlinetools.zip"
    curl -Lo "$CMDLINE_TOOLS_ZIP" "$CMDLINE_TOOLS_URL" 2>&1 | tee -a "$LOG_FILE"

    # Extract to the correct location
    unzip -q "$CMDLINE_TOOLS_ZIP" -d "/tmp/cmdline-tools-temp" 2>&1 | tee -a "$LOG_FILE"
    mv /tmp/cmdline-tools-temp/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
    rm -rf /tmp/cmdline-tools-temp "$CMDLINE_TOOLS_ZIP"
fi

# Add Android SDK to PATH
if ! pattern_in_file 'ANDROID_HOME' ~/.bashrc; then
    log_info "Adding Android SDK to PATH..."
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

# Accept licenses and install SDK packages if sdkmanager exists
if file_exists "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"; then
    # Check if platform-tools is installed (indicator that SDK packages are set up)
    if dir_exists "$ANDROID_HOME/platform-tools"; then
        log_skip "Android SDK packages"
    else
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
            "extras;google;m2repository" 2>&1 | tee -a "$LOG_FILE"
    fi
fi

# Install Gradle
GRADLE_VERSION="8.12"
if command_exists gradle && gradle --version 2>&1 | grep -q "$GRADLE_VERSION"; then
    log_skip "Gradle $GRADLE_VERSION"
else
    log_info "Installing Gradle $GRADLE_VERSION..."
    GRADLE_ZIP="/tmp/gradle.zip"
    curl -Lo "$GRADLE_ZIP" "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" 2>&1 | tee -a "$LOG_FILE"
    sudo unzip -q "$GRADLE_ZIP" -d /opt 2>&1 | tee -a "$LOG_FILE"
    sudo ln -sf "/opt/gradle-${GRADLE_VERSION}/bin/gradle" /usr/local/bin/gradle
    rm "$GRADLE_ZIP"
fi

log_success "Android development environment installed"
log_info "  - OpenJDK 17"
log_info "  - Android SDK (platforms 34, 35)"
log_info "  - Android Build Tools 35.0.0"
log_info "  - Android Platform Tools"
log_info "  - Gradle ${GRADLE_VERSION}"

################################################################################
# 13. ADDITIONAL DEVELOPMENT TOOLS
################################################################################

log_step "Step 13: Installing additional development tools..."

# Install GitHub CLI
if command_exists gh; then
    log_skip "GitHub CLI"
else
    log_info "Installing GitHub CLI..."
    (type -p wget >/dev/null || (sudo apt update && sudo apt install -y wget)) \
        && sudo mkdir -p -m 755 /etc/apt/keyrings \
        && wget -qO- https://cli.github.com/packages/githubkey.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update 2>&1 | tee -a "$LOG_FILE" \
        && sudo apt install -y gh 2>&1 | tee -a "$LOG_FILE"
fi

# Install lazygit (better git UI)
if command_exists lazygit; then
    log_skip "lazygit"
else
    log_info "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" 2>&1 | tee -a "$LOG_FILE"
    tar xf lazygit.tar.gz lazygit 2>&1 | tee -a "$LOG_FILE"
    sudo install lazygit /usr/local/bin 2>&1 | tee -a "$LOG_FILE"
    rm lazygit lazygit.tar.gz
fi

# Install fd (better find)
if package_installed fd-find; then
    log_skip "fd-find"
else
    log_info "Installing fd-find..."
    sudo apt install -y fd-find 2>&1 | tee -a "$LOG_FILE"
    sudo ln -sf $(which fdfind) /usr/local/bin/fd 2>/dev/null || true
fi

# Install ripgrep (better grep)
if package_installed ripgrep; then
    log_skip "ripgrep"
else
    log_info "Installing ripgrep..."
    sudo apt install -y ripgrep 2>&1 | tee -a "$LOG_FILE"
fi

# Install bat (better cat)
if package_installed bat; then
    log_skip "bat"
else
    log_info "Installing bat..."
    sudo apt install -y bat 2>&1 | tee -a "$LOG_FILE"
    sudo ln -sf /usr/bin/batcat /usr/local/bin/bat 2>/dev/null || true
fi

# Install exa (better ls)
if package_installed exa; then
    log_skip "exa"
else
    log_info "Installing exa..."
    sudo apt install -y exa 2>&1 | tee -a "$LOG_FILE"
fi

log_success "Additional development tools installed"

################################################################################
# 14. BASH ALIASES & ENVIRONMENT
################################################################################

log_step "Step 14: Setting up bash aliases and environment..."

# Check if aliases are already added (by looking for a unique marker)
if pattern_in_file 'Development Environment Aliases' ~/.bashrc; then
    log_skip "Bash aliases and environment"
else
    log_info "Adding bash aliases and environment..."
    
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

# AI Tools Aliases
alias ai='aider'
alias aic='aider --model sonnet'
alias aig='aider --model gpt-4o'
alias ask='sgpt'
# Note: Run 'ollama pull deepseek-coder' first to use this alias
alias ollama-code='ollama run deepseek-coder'

# Quick AI helpers
ask-cmd() {
    sgpt --shell "$@"
}

ask-code() {
    sgpt --code "$@"
}

# Git commit with AI review (shows diff first, requires confirmation)
gac() {
    echo "Staging all changes..."
    git add -A
    echo ""
    echo "Current changes:"
    git diff --cached --stat
    echo ""
    read -p "Proceed with AI-assisted commit review? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        aider --message "review and commit changes"
    else
        echo "Aborted. Changes remain staged."
    fi
}

# Quick edit configs
alias bashrc='vim ~/.bashrc'
alias tmuxconf='vim ~/.tmux.conf'

# Reload bash config
alias reload='source ~/.bashrc'

EOF

    log_success "Bash aliases and environment configured"
fi

################################################################################
# 15. SECURITY SETUP
################################################################################

log_step "Step 15: Configuring basic security..."

# Configure UFW firewall
if sudo ufw status | grep -q "Status: active"; then
    log_skip "UFW firewall (already active)"
else
    log_info "Configuring UFW firewall..."
    sudo ufw default deny incoming 2>&1 | tee -a "$LOG_FILE"
    sudo ufw default allow outgoing 2>&1 | tee -a "$LOG_FILE"
    sudo ufw allow ssh 2>&1 | tee -a "$LOG_FILE"
    sudo ufw allow http 2>&1 | tee -a "$LOG_FILE"
    sudo ufw allow https 2>&1 | tee -a "$LOG_FILE"
    sudo ufw --force enable 2>&1 | tee -a "$LOG_FILE"
    log_success "UFW firewall configured and enabled"
fi

# Configure fail2ban
if service_running fail2ban; then
    log_skip "fail2ban (already running)"
else
    log_info "Configuring fail2ban..."
    sudo systemctl enable fail2ban 2>&1 | tee -a "$LOG_FILE"
    sudo systemctl start fail2ban 2>&1 | tee -a "$LOG_FILE"
    log_success "fail2ban enabled and started"
fi

log_success "Basic security configured (UFW + fail2ban)"

################################################################################
# 16. WORKSPACE SETUP
################################################################################

log_step "Step 16: Creating workspace directories..."

# Create standard workspace structure only if directories don't exist
WORKSPACE_DIRS=(
    ~/projects/web
    ~/projects/api
    ~/projects/mobile
    ~/projects/automation
    ~/projects/experiments
    ~/backups
    ~/scripts
    ~/logs
)

DIRS_CREATED=0
for dir in "${WORKSPACE_DIRS[@]}"; do
    if ! dir_exists "$dir"; then
        mkdir -p "$dir" 2>&1 | tee -a "$LOG_FILE"
        ((DIRS_CREATED++))
    fi
done

if [ $DIRS_CREATED -eq 0 ]; then
    log_skip "Workspace directories"
else
    log_success "Created $DIRS_CREATED workspace directories"
fi

################################################################################
# 17. SYSTEM INFO & FINAL STEPS
################################################################################

echo ""
echo "============================================================================"
log_success "VPS Development Environment Setup Complete!"
echo "============================================================================"
echo ""

# Log completion
log_info "Setup completed at $(date)"
log_info "Full log available at: $LOG_FILE"
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
    echo "    Gradle:       $(gradle --version 2>&1 | grep Gradle | cut -d' ' -f2)"
fi
if [ -d "$ANDROID_HOME" ]; then
    echo "    Android SDK:  $ANDROID_HOME"
    echo "    Build Tools:  35.0.0"
    echo "    Platforms:    android-34, android-35"
fi
echo ""
echo "  AI CLI Tools:"
if command -v sgpt &> /dev/null; then
    echo "    Shell-GPT:    $(sgpt --version 2>/dev/null || echo 'installed')"
fi
if command -v aider &> /dev/null; then
    echo "    Aider:        $(aider --version 2>/dev/null || echo 'installed')"
fi
if command -v ollama &> /dev/null; then
    echo "    Ollama:       $(ollama --version 2>/dev/null || echo 'installed')"
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
echo "  5. Configure AI API keys (optional):"
echo "     export OPENAI_API_KEY='your-openai-key'       # For Shell-GPT, Aider with GPT"
echo "     export ANTHROPIC_API_KEY='your-anthropic-key' # For Aider with Claude"
echo "     # Add these to ~/.bashrc for persistence"
echo ""
echo "  6. Download a local model for Ollama (optional):"
echo "     ollama pull deepseek-coder    # For coding tasks"
echo "     ollama pull llama3            # General purpose"
echo ""
echo "  7. Start a tmux session:"
echo "     tmux new -s work"
echo ""
echo "  8. Clone your repositories:"
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
echo "  AI Tools:"
echo "    cc                        - Claude Code"
echo "    ai / aider                - AI pair programming"
echo "    aic                       - Aider with Claude Sonnet"
echo "    aig                       - Aider with GPT-4o"
echo "    ask / sgpt                - Shell-GPT CLI assistant"
echo "    ask-cmd '<query>'         - Get shell commands"
echo "    ask-code '<query>'        - Generate code"
echo "    ollama run <model>        - Run local LLM"
echo "    gac                       - Git add + AI commit"
echo ""
echo "============================================================================"

log_success "Setup script completed successfully!"
echo ""
log_info "Log file: $LOG_FILE"
log_info "Run 'source ~/.bashrc' to apply aliases, or log out and log back in."
echo ""
