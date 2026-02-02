#!/bin/bash

################################################################################
# VPS Development Environment Verification Script
# Purpose: Verify all components were installed correctly
################################################################################

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check function
check_command() {
    local cmd=$1
    local name=$2
    local version_cmd=$3
    
    if command -v $cmd &> /dev/null; then
        local version=""
        if [ -n "$version_cmd" ]; then
            version=$($version_cmd 2>&1 | head -n1)
        fi
        echo -e "${GREEN}✓${NC} $name ${BLUE}$version${NC}"
        return 0
    else
        echo -e "${RED}✗${NC} $name ${YELLOW}(not found)${NC}"
        return 1
    fi
}

check_service() {
    local service=$1
    local name=$2
    
    if systemctl is-active --quiet $service; then
        echo -e "${GREEN}✓${NC} $name ${BLUE}(running)${NC}"
        return 0
    else
        echo -e "${RED}✗${NC} $name ${YELLOW}(not running)${NC}"
        return 1
    fi
}

echo "============================================================================"
echo -e "${BLUE}VPS Development Environment Verification${NC}"
echo "============================================================================"
echo ""

# System Info
echo -e "${YELLOW}System Information:${NC}"
echo "  OS:        $(lsb_release -ds)"
echo "  Kernel:    $(uname -r)"
echo "  Hostname:  $(hostname)"
echo "  Uptime:    $(uptime -p)"
echo ""

# Core Tools
echo -e "${YELLOW}Core Development Tools:${NC}"
check_command git "Git" "git --version"
check_command tmux "Tmux" "tmux -V"
check_command vim "Vim" "vim --version | head -n1"
check_command htop "htop" ""
check_command btop "btop" ""
check_command ncdu "ncdu" "ncdu --version"
check_command tree "tree" "tree --version"
check_command jq "jq" "jq --version"
echo ""

# Docker
echo -e "${YELLOW}Containerization:${NC}"
check_command docker "Docker" "docker --version"
check_command "docker compose" "Docker Compose" "docker compose version"
check_service docker "Docker Service"
echo ""

# Node.js Ecosystem
echo -e "${YELLOW}Node.js Ecosystem:${NC}"
# Check if NVM is loaded
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    . "$HOME/.nvm/nvm.sh"
fi
check_command nvm "NVM" "nvm --version"
check_command node "Node.js" "node --version"
check_command npm "npm" "npm --version"
check_command pnpm "pnpm" "pnpm --version"
check_command yarn "yarn" "yarn --version"
check_command pm2 "PM2" "pm2 --version"
check_command tsc "TypeScript" "tsc --version"
check_command nest "NestJS CLI" "nest --version"
echo ""

# .NET
echo -e "${YELLOW}.NET Development:${NC}"
check_command dotnet ".NET SDK" "dotnet --version"
if command -v dotnet &> /dev/null; then
    echo "  Installed SDKs:"
    dotnet --list-sdks | while read line; do
        echo "    - $line"
    done
    echo "  Installed Runtimes:"
    dotnet --list-runtimes | while read line; do
        echo "    - $line"
    done
fi
echo ""

# Python
echo -e "${YELLOW}Python Environment:${NC}"
check_command python3 "Python" "python3 --version"
check_command pip3 "pip" "pip3 --version"
check_command pipenv "pipenv" "pipenv --version"
check_command poetry "poetry" "poetry --version"
check_command ipython "IPython" "ipython --version"
check_command black "black" "black --version"
echo ""

# PHP
echo -e "${YELLOW}PHP Development:${NC}"
check_command php "PHP" "php --version | head -n1"
check_command composer "Composer" "composer --version"
if command -v php &> /dev/null; then
    echo "  Loaded Extensions:"
    php -m | grep -E "(mysql|pgsql|redis|curl|gd|mbstring|xml)" | while read ext; do
        echo "    - $ext"
    done
fi
echo ""

# Database Clients
echo -e "${YELLOW}Database Clients:${NC}"
check_command mysql "MySQL Client" "mysql --version"
check_command psql "PostgreSQL Client" "psql --version"
check_command redis-cli "Redis CLI" "redis-cli --version"
check_command sqlite3 "SQLite" "sqlite3 --version"
check_command mongosh "MongoDB Shell" "mongosh --version"
echo ""

# Developer Tools
echo -e "${YELLOW}Additional Developer Tools:${NC}"
check_command claude-code "Claude Code CLI" "claude-code --version"
check_command gh "GitHub CLI" "gh --version | head -n1"
check_command lazygit "lazygit" "lazygit --version"
check_command fd "fd (find)" "fd --version"
check_command rg "ripgrep" "rg --version"
check_command bat "bat (cat)" "bat --version"
check_command exa "exa (ls)" "exa --version"
echo ""

# Security
echo -e "${YELLOW}Security:${NC}"
check_command ufw "UFW Firewall" "ufw --version"
check_service fail2ban "fail2ban"
check_command certbot "certbot" "certbot --version"
echo ""

# UFW Status
if command -v ufw &> /dev/null; then
    echo -e "${YELLOW}Firewall Rules:${NC}"
    sudo ufw status | grep -v "^$" | while read line; do
        echo "  $line"
    done
    echo ""
fi

# Disk Space
echo -e "${YELLOW}Disk Usage:${NC}"
df -h / | tail -n1 | awk '{print "  Root:      " $2 " total, " $3 " used, " $4 " available (" $5 " used)"}'
echo ""

# Memory
echo -e "${YELLOW}Memory Usage:${NC}"
free -h | grep "Mem:" | awk '{print "  Total:     " $2 "\n  Used:      " $3 "\n  Available: " $7}'
echo ""

# Docker Status
if command -v docker &> /dev/null && systemctl is-active --quiet docker; then
    echo -e "${YELLOW}Docker Status:${NC}"
    echo "  Containers: $(docker ps -q | wc -l) running, $(docker ps -aq | wc -l) total"
    echo "  Images:     $(docker images -q | wc -l)"
    echo "  Volumes:    $(docker volume ls -q | wc -l)"
    echo "  Networks:   $(docker network ls -q | wc -l)"
    echo ""
fi

# Check workspace directories
echo -e "${YELLOW}Workspace Directories:${NC}"
for dir in projects projects/web projects/api projects/mobile projects/automation projects/experiments backups scripts logs; do
    if [ -d "$HOME/$dir" ]; then
        echo -e "  ${GREEN}✓${NC} ~/$dir"
    else
        echo -e "  ${RED}✗${NC} ~/$dir ${YELLOW}(missing)${NC}"
    fi
done
echo ""

# Check configuration files
echo -e "${YELLOW}Configuration Files:${NC}"
for file in .bashrc .tmux.conf .gitconfig; do
    if [ -f "$HOME/$file" ]; then
        echo -e "  ${GREEN}✓${NC} ~/$file"
    else
        echo -e "  ${RED}✗${NC} ~/$file ${YELLOW}(missing)${NC}"
    fi
done
echo ""

# Git configuration
echo -e "${YELLOW}Git Configuration:${NC}"
if [ -n "$(git config --global user.name)" ]; then
    echo -e "  ${GREEN}✓${NC} user.name:  $(git config --global user.name)"
else
    echo -e "  ${RED}✗${NC} user.name:  ${YELLOW}(not set)${NC}"
fi

if [ -n "$(git config --global user.email)" ]; then
    echo -e "  ${GREEN}✓${NC} user.email: $(git config --global user.email)"
else
    echo -e "  ${RED}✗${NC} user.email: ${YELLOW}(not set)${NC}"
fi
echo ""

# SSH Keys
echo -e "${YELLOW}SSH Keys:${NC}"
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    echo -e "  ${GREEN}✓${NC} Ed25519 key exists"
elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
    echo -e "  ${GREEN}✓${NC} RSA key exists"
else
    echo -e "  ${YELLOW}!${NC} No SSH keys found ${YELLOW}(generate with: ssh-keygen -t ed25519)${NC}"
fi
echo ""

# Tmux sessions
echo -e "${YELLOW}Active Tmux Sessions:${NC}"
if command -v tmux &> /dev/null; then
    if tmux list-sessions 2>/dev/null; then
        :
    else
        echo "  No active sessions"
    fi
else
    echo "  Tmux not installed"
fi
echo ""

# Summary
echo "============================================================================"
echo -e "${GREEN}Verification Complete!${NC}"
echo "============================================================================"
echo ""
echo -e "${BLUE}Quick Test Commands:${NC}"
echo "  node --version          # Test Node.js"
echo "  docker run hello-world  # Test Docker"
echo "  claude-code --help      # Test Claude Code"
echo "  tmux new -s test        # Test Tmux"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Configure Git if not done:"
echo "     git config --global user.name 'Your Name'"
echo "     git config --global user.email 'your@email.com'"
echo ""
echo "  2. Generate SSH keys for GitHub (if needed):"
echo "     ssh-keygen -t ed25519 -C 'your@email.com'"
echo ""
echo "  3. Authenticate Claude Code:"
echo "     claude-code auth"
echo ""
echo "  4. Start working:"
echo "     tmux new -s work"
echo "     cd ~/projects"
echo ""
