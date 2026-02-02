#!/bin/bash

################################################################################
# OpenClaw Installation Script for VPS Development Environment
# Target: Ubuntu 24.04 LTS (after vps-dev-setup.sh)
# Purpose: Optional add-on to install OpenClaw AI assistant with Gateway service
# Repository: https://github.com/suporterfid/dev-vps
# Date: February 2026
################################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

################################################################################
# LOGGING SETUP
################################################################################

# Setup log file with timestamp
LOG_DIR="$HOME/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/openclaw-setup-$(date +%Y%m%d-%H%M%S).log"
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

log_security() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${CYAN}[SECURITY]${NC} $1"
    echo "[$timestamp] [SECURITY] $1" >> "$LOG_FILE"
}

################################################################################
# VERIFICATION FUNCTIONS
################################################################################

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if a file exists
file_exists() {
    [ -f "$1" ]
}

# Check if a directory exists
dir_exists() {
    [ -d "$1" ]
}

# Check if a user service is running
user_service_running() {
    systemctl --user is-active --quiet "$1" 2>/dev/null
}

# Check if a user service exists
user_service_exists() {
    systemctl --user list-unit-files "$1" &>/dev/null 2>&1
}

# Check if a grep pattern exists in a file
pattern_in_file() {
    local pattern="$1"
    local file="$2"
    grep -q "$pattern" "$file" 2>/dev/null
}

# Get Node.js major version
get_node_major_version() {
    if command_exists node; then
        node --version 2>/dev/null | sed 's/v//' | cut -d. -f1
    else
        echo "0"
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
    echo ""
    log_error "If the installation failed, you can safely re-run this script."
    log_error "To completely uninstall OpenClaw, run:"
    log_error "  npm uninstall -g openclaw"
    log_error "  systemctl --user stop openclaw-gateway"
    log_error "  systemctl --user disable openclaw-gateway"
    log_error "  rm -rf ~/.openclaw ~/.config/systemd/user/openclaw-gateway.service"
    exit $exit_code
}

# Set error trap
trap 'handle_error $LINENO' ERR

################################################################################
# PRE-FLIGHT CHECKS
################################################################################

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    log_error "Please do not run this script as root. Run as regular user with sudo privileges."
    exit 1
fi

# Print banner
echo -e "${CYAN}"
cat << 'EOF'
 ____                    ____ _
/ __ \                  / ___| |
| |  | |_ __   ___ _ __ | |   | | __ ___      __
| |  | | '_ \ / _ \ '_ \| |   | |/ _` \ \ /\ / /
| |__| | |_) |  __/ | | | |___| | (_| |\ V  V /
 \____/| .__/ \___|_| |_|\____|_|\__,_| \_/\_/
       | |
       |_|     VPS Development Environment Add-on
EOF
echo -e "${NC}"

log_info "Starting OpenClaw Installation..."
log_info "Prerequisites: vps-dev-setup.sh must have been run first"
log_info "Log file: $LOG_FILE"
echo ""

################################################################################
# 1. PREREQUISITES CHECK
################################################################################

log_step "Step 1: Checking prerequisites from vps-dev-setup.sh..."

PREREQUISITES_MET=true

# Check NVM
export NVM_DIR="$HOME/.nvm"
if dir_exists "$NVM_DIR" && file_exists "$NVM_DIR/nvm.sh"; then
    # Load NVM
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    log_success "NVM is installed"
else
    log_error "NVM is not installed. Please run vps-dev-setup.sh first."
    PREREQUISITES_MET=false
fi

# Check Node.js
if command_exists node; then
    CURRENT_NODE_VERSION=$(node --version)
    log_success "Node.js is installed ($CURRENT_NODE_VERSION)"
else
    log_error "Node.js is not installed. Please run vps-dev-setup.sh first."
    PREREQUISITES_MET=false
fi

# Check Docker (required for sandbox mode)
if command_exists docker; then
    log_success "Docker is installed"
else
    log_warning "Docker is not installed. Sandbox mode will not work."
    log_warning "Install Docker via vps-dev-setup.sh for full functionality."
fi

# Check tmux
if command_exists tmux; then
    log_success "tmux is installed"
else
    log_warning "tmux is not installed. Recommended for persistent sessions."
fi

# Check git
if command_exists git; then
    log_success "git is installed"
else
    log_error "git is not installed. Please run vps-dev-setup.sh first."
    PREREQUISITES_MET=false
fi

if [ "$PREREQUISITES_MET" = false ]; then
    log_error "Prerequisites not met. Please run vps-dev-setup.sh first:"
    log_error "  ./vps-dev-setup.sh"
    exit 1
fi

log_success "All prerequisites verified"

################################################################################
# 2. NODE.JS UPGRADE TO v22+
################################################################################

log_step "Step 2: Upgrading Node.js to v22+ (required by OpenClaw)..."

REQUIRED_NODE_MAJOR=22
NODE_VERSION_22="22"  # Latest LTS in the 22.x line

# Ensure NVM is loaded
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

CURRENT_NODE_MAJOR=$(get_node_major_version)

if [ "$CURRENT_NODE_MAJOR" -ge "$REQUIRED_NODE_MAJOR" ]; then
    log_skip "Node.js v$REQUIRED_NODE_MAJOR+ (currently v$(node --version))"
else
    log_info "Current Node.js version: v$(node --version)"
    log_info "OpenClaw requires Node.js v$REQUIRED_NODE_MAJOR or higher"
    log_info "Upgrading Node.js..."

    # Install Node.js 22
    nvm install $NODE_VERSION_22 2>&1 | tee -a "$LOG_FILE"
    nvm use $NODE_VERSION_22 2>&1 | tee -a "$LOG_FILE"
    nvm alias default $NODE_VERSION_22 2>&1 | tee -a "$LOG_FILE"

    log_success "Node.js upgraded to $(node --version)"
    log_info "Node.js $(node --version) is now the default version"

    # Note about existing projects
    log_warning "Note: Your existing Node.js projects may need to be tested with v22"
    log_warning "To switch back to Node.js 20: nvm use 20"
fi

# Verify npm is available
if command_exists npm; then
    log_success "npm is available ($(npm --version))"
else
    log_error "npm is not available after Node.js upgrade"
    exit 1
fi

################################################################################
# 3. OPENCLAW INSTALLATION
################################################################################

log_step "Step 3: Installing OpenClaw via npm..."

# Check if OpenClaw is already installed
if command_exists openclaw; then
    CURRENT_VERSION=$(openclaw --version 2>/dev/null || echo "unknown")
    log_warning "OpenClaw is already installed (version: $CURRENT_VERSION)"

    read -p "Do you want to upgrade/reinstall OpenClaw? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Upgrading OpenClaw..."
        npm install -g openclaw@latest 2>&1 | tee -a "$LOG_FILE"
        log_success "OpenClaw upgraded to latest version"
    else
        log_skip "OpenClaw installation"
    fi
else
    log_info "Installing OpenClaw globally..."
    npm install -g openclaw@latest 2>&1 | tee -a "$LOG_FILE"
    log_success "OpenClaw installed successfully"
fi

# Verify installation
if command_exists openclaw; then
    OPENCLAW_VERSION=$(openclaw --version 2>/dev/null || echo "installed")
    log_success "OpenClaw verified: $OPENCLAW_VERSION"
else
    log_error "OpenClaw installation verification failed"
    exit 1
fi

################################################################################
# 4. WORKSPACE AND CONFIGURATION SETUP
################################################################################

log_step "Step 4: Setting up OpenClaw workspace and configuration..."

OPENCLAW_HOME="$HOME/.openclaw"
OPENCLAW_WORKSPACE="$OPENCLAW_HOME/workspace"
OPENCLAW_CONFIG="$OPENCLAW_HOME/openclaw.json"
OPENCLAW_LOG_DIR="$HOME/logs/openclaw"

# Create directory structure
log_info "Creating OpenClaw directory structure..."
mkdir -p "$OPENCLAW_HOME"
mkdir -p "$OPENCLAW_WORKSPACE"
mkdir -p "$OPENCLAW_LOG_DIR"

log_success "Created directories:"
log_info "  - Config home: $OPENCLAW_HOME"
log_info "  - Workspace: $OPENCLAW_WORKSPACE"
log_info "  - Logs: $OPENCLAW_LOG_DIR"

# Create configuration file with secure defaults
if file_exists "$OPENCLAW_CONFIG"; then
    log_warning "Configuration file already exists: $OPENCLAW_CONFIG"
    log_info "Backing up existing configuration..."
    cp "$OPENCLAW_CONFIG" "$OPENCLAW_CONFIG.backup.$(date +%Y%m%d-%H%M%S)"

    read -p "Do you want to replace the configuration with secure defaults? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_skip "Configuration file creation"
    else
        CREATE_CONFIG=true
    fi
else
    CREATE_CONFIG=true
fi

if [ "${CREATE_CONFIG:-false}" = true ] || [ ! -f "$OPENCLAW_CONFIG" ]; then
    log_info "Creating OpenClaw configuration with secure defaults..."
    log_security "Gateway will bind to loopback only (127.0.0.1)"
    log_security "All messaging channels disabled by default"
    log_security "Pairing mode enabled for all channels"
    log_security "Sandbox mode enabled for non-main sessions"

    cat > "$OPENCLAW_CONFIG" << 'EOF'
{
  "$schema": "https://docs.openclaw.ai/schema/config.json",
  "agent": {
    "model": "anthropic/claude-sonnet-4-5",
    "maxTokens": 8192,
    "temperature": 0.7
  },
  "gateway": {
    "port": 18789,
    "bind": "loopback",
    "auth": {
      "mode": "password",
      "allowTailscale": false
    },
    "rateLimit": {
      "enabled": true,
      "maxRequests": 60,
      "windowMs": 60000
    }
  },
  "channels": {
    "whatsapp": {
      "enabled": false,
      "dm": {
        "policy": "pairing",
        "allowFrom": []
      }
    },
    "telegram": {
      "enabled": false,
      "dm": {
        "policy": "pairing",
        "allowFrom": []
      }
    },
    "discord": {
      "enabled": false,
      "dm": {
        "policy": "pairing",
        "allowFrom": []
      },
      "guilds": {
        "policy": "explicit",
        "allowFrom": []
      }
    },
    "slack": {
      "enabled": false,
      "dm": {
        "policy": "pairing",
        "allowFrom": []
      }
    }
  },
  "agents": {
    "defaults": {
      "workspace": "~/.openclaw/workspace",
      "sandbox": {
        "mode": "non-main",
        "allowlist": [
          "bash",
          "process",
          "read",
          "write",
          "edit",
          "sessions_list",
          "sessions_history",
          "sessions_send"
        ],
        "denylist": [
          "browser",
          "canvas",
          "nodes",
          "cron",
          "discord",
          "gateway"
        ]
      },
      "timeout": 300000,
      "maxTurns": 50
    }
  },
  "security": {
    "audit": {
      "enabled": true,
      "logPath": "~/logs/openclaw/audit.log"
    },
    "fileAccess": {
      "mode": "workspace",
      "allowPaths": [
        "~/.openclaw/workspace",
        "~/dev",
        "~/projects"
      ],
      "denyPaths": [
        "~/.ssh",
        "~/.gnupg",
        "~/.aws",
        "/etc"
      ]
    }
  },
  "logging": {
    "level": "info",
    "file": "~/logs/openclaw/openclaw.log",
    "maxSize": "10MB",
    "maxFiles": 5
  }
}
EOF

    log_success "Configuration file created: $OPENCLAW_CONFIG"
fi

################################################################################
# 5. SYSTEMD USER SERVICE SETUP
################################################################################

log_step "Step 5: Setting up OpenClaw Gateway as systemd user service..."

SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SYSTEMD_USER_DIR/openclaw-gateway.service"

# Create systemd user directory
mkdir -p "$SYSTEMD_USER_DIR"

# Enable lingering for user services to persist after logout
if ! loginctl show-user "$USER" --property=Linger 2>/dev/null | grep -q "Linger=yes"; then
    log_info "Enabling user service lingering (allows services to run after logout)..."
    sudo loginctl enable-linger "$USER" 2>&1 | tee -a "$LOG_FILE"
    log_success "User lingering enabled"
else
    log_skip "User lingering (already enabled)"
fi

# Get the path to openclaw binary
OPENCLAW_BIN=$(which openclaw)
NODE_BIN=$(which node)

# Create systemd service file
if file_exists "$SERVICE_FILE"; then
    log_warning "Service file already exists. Backing up..."
    cp "$SERVICE_FILE" "$SERVICE_FILE.backup.$(date +%Y%m%d-%H%M%S)"
fi

log_info "Creating systemd service file..."
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=OpenClaw Gateway Service
Documentation=https://docs.openclaw.ai/gateway
After=network.target

[Service]
Type=simple
Environment=NODE_ENV=production
Environment=NVM_DIR=$HOME/.nvm
Environment=PATH=$HOME/.nvm/versions/node/v$NODE_VERSION_22/bin:/usr/local/bin:/usr/bin:/bin
Environment=HOME=$HOME
Environment=OPENCLAW_CONFIG=$OPENCLAW_CONFIG
WorkingDirectory=$OPENCLAW_HOME
ExecStart=$OPENCLAW_BIN gateway start --config $OPENCLAW_CONFIG
ExecStop=$OPENCLAW_BIN gateway stop
Restart=on-failure
RestartSec=10
StandardOutput=append:$OPENCLAW_LOG_DIR/gateway.log
StandardError=append:$OPENCLAW_LOG_DIR/gateway-error.log

# Security hardening
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=$OPENCLAW_HOME $OPENCLAW_LOG_DIR $HOME/dev $HOME/projects
PrivateTmp=true

[Install]
WantedBy=default.target
EOF

log_success "Service file created: $SERVICE_FILE"

# Reload systemd user daemon
log_info "Reloading systemd user daemon..."
systemctl --user daemon-reload 2>&1 | tee -a "$LOG_FILE"

# Enable the service (but don't start it yet)
log_info "Enabling OpenClaw Gateway service..."
systemctl --user enable openclaw-gateway 2>&1 | tee -a "$LOG_FILE"

log_success "OpenClaw Gateway service configured"
log_info "Service is enabled but NOT started (security: requires manual configuration first)"
log_info "To start: systemctl --user start openclaw-gateway"

################################################################################
# 6. BASH ALIASES AND FUNCTIONS
################################################################################

log_step "Step 6: Adding OpenClaw aliases and functions to .bashrc..."

BASHRC="$HOME/.bashrc"

# Check if OpenClaw section already exists
if pattern_in_file '# OpenClaw Configuration' "$BASHRC"; then
    log_warning "OpenClaw configuration already exists in .bashrc"
    read -p "Do you want to replace the existing configuration? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Remove existing OpenClaw section
        sed -i '/# OpenClaw Configuration/,/# End OpenClaw Configuration/d' "$BASHRC"
        ADD_ALIASES=true
    else
        log_skip "Bash aliases"
        ADD_ALIASES=false
    fi
else
    ADD_ALIASES=true
fi

if [ "$ADD_ALIASES" = true ]; then
    log_info "Adding OpenClaw aliases to .bashrc..."

    cat >> "$BASHRC" << 'EOF'

# OpenClaw Configuration
# Added by openclaw-setup.sh
# Documentation: https://docs.openclaw.ai

# OpenClaw aliases
alias oc='openclaw'
alias oc-chat='openclaw chat'
alias oc-code='openclaw code'

# Gateway management (systemd user service)
alias oc-status='systemctl --user status openclaw-gateway'
alias oc-start='systemctl --user start openclaw-gateway'
alias oc-stop='systemctl --user stop openclaw-gateway'
alias oc-restart='systemctl --user restart openclaw-gateway'
alias oc-enable='systemctl --user enable openclaw-gateway'
alias oc-disable='systemctl --user disable openclaw-gateway'

# Logs
alias oc-logs='journalctl --user -u openclaw-gateway -f'
alias oc-logs-all='journalctl --user -u openclaw-gateway --no-pager'
alias oc-logs-error='tail -f ~/logs/openclaw/gateway-error.log'

# Configuration
alias oc-config='${EDITOR:-nano} ~/.openclaw/openclaw.json'
alias oc-config-validate='openclaw config validate'

# Workspace
alias oc-workspace='cd ~/.openclaw/workspace'

# Helper function: Quick status check
oc-check() {
    echo "=== OpenClaw Status ==="
    echo "Version: $(openclaw --version 2>/dev/null || echo 'not found')"
    echo "Node.js: $(node --version 2>/dev/null || echo 'not found')"
    echo ""
    echo "=== Gateway Service ==="
    systemctl --user status openclaw-gateway --no-pager 2>/dev/null || echo "Service not found or not running"
    echo ""
    echo "=== Configuration ==="
    if [ -f ~/.openclaw/openclaw.json ]; then
        echo "Config: ~/.openclaw/openclaw.json (exists)"
        echo "Gateway port: $(grep -o '"port": [0-9]*' ~/.openclaw/openclaw.json | head -1 | grep -o '[0-9]*')"
    else
        echo "Config: not found"
    fi
}

# Helper function: Setup a messaging channel
oc-setup-channel() {
    local channel=$1
    if [ -z "$channel" ]; then
        echo "Usage: oc-setup-channel <whatsapp|telegram|discord|slack>"
        echo ""
        echo "This will open the configuration file for you to enable and configure the channel."
        echo "Remember to restart the gateway after making changes: oc-restart"
        return 1
    fi
    echo "Opening configuration to set up $channel channel..."
    echo "Documentation: https://docs.openclaw.ai/channels/$channel"
    ${EDITOR:-nano} ~/.openclaw/openclaw.json
}

# End OpenClaw Configuration
EOF

    log_success "Bash aliases added to .bashrc"
    log_info "Run 'source ~/.bashrc' or open a new terminal to use the aliases"
fi

################################################################################
# 7. SECURITY HARDENING
################################################################################

log_step "Step 7: Applying security hardening..."

log_security "Reviewing security configuration..."

# Set correct permissions on config files
log_info "Setting secure permissions on configuration files..."
chmod 600 "$OPENCLAW_CONFIG" 2>/dev/null || true
chmod 700 "$OPENCLAW_HOME" 2>/dev/null || true
chmod 700 "$OPENCLAW_WORKSPACE" 2>/dev/null || true

log_success "Configuration files secured (600/700 permissions)"

# Security warnings
echo ""
log_security "=== IMPORTANT SECURITY INFORMATION ==="
echo ""
log_security "1. Gateway binds to LOOPBACK ONLY (127.0.0.1) by default"
log_security "   - This means it's only accessible from the VPS itself"
log_security "   - To access remotely, use SSH tunneling or Tailscale"
echo ""
log_security "2. All messaging channels are DISABLED by default"
log_security "   - Enable only channels you need in ~/.openclaw/openclaw.json"
log_security "   - Each channel requires explicit configuration"
echo ""
log_security "3. Pairing mode is ENABLED for all channels"
log_security "   - New contacts must complete pairing before interaction"
log_security "   - This prevents unauthorized access"
echo ""
log_security "4. Sandbox mode is enabled for non-main sessions"
log_security "   - Requires Docker to be running"
log_security "   - Limits tool access for enhanced security"
echo ""
log_security "5. For remote access documentation, see:"
log_security "   https://docs.openclaw.ai/gateway/security"
log_security "   or run: cat docs/OPENCLAW.md (after installation)"
echo ""

################################################################################
# 8. POST-INSTALLATION VERIFICATION
################################################################################

log_step "Step 8: Post-installation verification..."

VERIFICATION_PASSED=true

# Verify OpenClaw installation
if command_exists openclaw; then
    log_success "OpenClaw CLI: $(openclaw --version 2>/dev/null || echo 'installed')"
else
    log_error "OpenClaw CLI not found in PATH"
    VERIFICATION_PASSED=false
fi

# Verify Node.js version
NODE_MAJOR=$(get_node_major_version)
if [ "$NODE_MAJOR" -ge "$REQUIRED_NODE_MAJOR" ]; then
    log_success "Node.js version: v$(node --version) (meets requirement >= v$REQUIRED_NODE_MAJOR)"
else
    log_error "Node.js version v$(node --version) does not meet requirement >= v$REQUIRED_NODE_MAJOR"
    VERIFICATION_PASSED=false
fi

# Verify configuration file
if file_exists "$OPENCLAW_CONFIG"; then
    log_success "Configuration file: $OPENCLAW_CONFIG"
else
    log_error "Configuration file not found: $OPENCLAW_CONFIG"
    VERIFICATION_PASSED=false
fi

# Verify systemd service
if file_exists "$SERVICE_FILE"; then
    log_success "Systemd service file: $SERVICE_FILE"
else
    log_error "Systemd service file not found: $SERVICE_FILE"
    VERIFICATION_PASSED=false
fi

# Verify workspace
if dir_exists "$OPENCLAW_WORKSPACE"; then
    log_success "Workspace directory: $OPENCLAW_WORKSPACE"
else
    log_error "Workspace directory not found: $OPENCLAW_WORKSPACE"
    VERIFICATION_PASSED=false
fi

# Verify log directory
if dir_exists "$OPENCLAW_LOG_DIR"; then
    log_success "Log directory: $OPENCLAW_LOG_DIR"
else
    log_error "Log directory not found: $OPENCLAW_LOG_DIR"
    VERIFICATION_PASSED=false
fi

echo ""
if [ "$VERIFICATION_PASSED" = true ]; then
    log_success "All verifications passed!"
else
    log_error "Some verifications failed. Check the errors above."
fi

################################################################################
# 9. USAGE INSTRUCTIONS
################################################################################

log_step "Step 9: Installation complete!"

echo ""
echo -e "${GREEN}=== OpenClaw Installation Summary ===${NC}"
echo ""
echo "OpenClaw has been installed with the following components:"
echo "  - OpenClaw CLI: $(openclaw --version 2>/dev/null || echo 'installed')"
echo "  - Node.js: $(node --version)"
echo "  - Configuration: $OPENCLAW_CONFIG"
echo "  - Workspace: $OPENCLAW_WORKSPACE"
echo "  - Logs: $OPENCLAW_LOG_DIR"
echo ""
echo -e "${CYAN}=== Next Steps ===${NC}"
echo ""
echo "1. Source your updated .bashrc:"
echo "   source ~/.bashrc"
echo ""
echo "2. Complete the OpenClaw onboarding:"
echo "   openclaw onboard"
echo ""
echo "3. Set your API key (if not done during onboard):"
echo "   openclaw config set apiKey YOUR_ANTHROPIC_API_KEY"
echo ""
echo "4. Start the OpenClaw Gateway (optional):"
echo "   oc-start     # or: systemctl --user start openclaw-gateway"
echo ""
echo "5. Check Gateway status:"
echo "   oc-status    # or: systemctl --user status openclaw-gateway"
echo ""
echo -e "${CYAN}=== Quick Commands ===${NC}"
echo ""
echo "  oc-check      - View overall status"
echo "  oc-start      - Start the Gateway service"
echo "  oc-stop       - Stop the Gateway service"
echo "  oc-logs       - View Gateway logs (live)"
echo "  oc-config     - Edit configuration"
echo "  oc-workspace  - Go to workspace directory"
echo ""
echo -e "${YELLOW}=== Security Reminders ===${NC}"
echo ""
echo "  - Gateway is bound to localhost only (127.0.0.1:18789)"
echo "  - All messaging channels are DISABLED by default"
echo "  - Enable channels only after reviewing security docs"
echo "  - For remote access, use SSH tunnel or Tailscale"
echo ""
echo "Documentation:"
echo "  - OpenClaw Docs: https://docs.openclaw.ai"
echo "  - Security Guide: https://docs.openclaw.ai/gateway/security"
echo "  - Local docs: docs/OPENCLAW.md (if created)"
echo ""
echo "Log file: $LOG_FILE"
echo ""
log_success "OpenClaw installation completed successfully!"
