# OpenClaw VPS Setup Guide

Comprehensive documentation for deploying OpenClaw on your VPS development environment.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Channel Setup](#channel-setup)
  - [WhatsApp](#whatsapp-setup)
  - [Telegram](#telegram-setup)
  - [Discord](#discord-setup)
  - [Slack](#slack-setup)
- [Security Best Practices](#security-best-practices)
- [Remote Access](#remote-access)
- [Workflows & Use Cases](#workflows--use-cases)
- [Troubleshooting](#troubleshooting)
- [Reference](#reference)

---

## Overview

OpenClaw is a personal AI assistant that lets you interact with AI through messaging platforms. When deployed on your VPS, it provides:

- **Multi-channel communication**: Chat via WhatsApp, Telegram, Discord, or Slack
- **Persistent sessions**: Conversations continue across device switches
- **Code execution**: Run commands and edit files through chat
- **Secure isolation**: Sandbox mode for untrusted operations
- **Gateway service**: Always-on service accessible from anywhere

### Architecture

```
                                    ┌─────────────────────────────────────┐
                                    │           VPS Server                │
┌──────────────┐                    │  ┌───────────────────────────────┐  │
│   WhatsApp   │────┐               │  │     OpenClaw Gateway          │  │
├──────────────┤    │               │  │   (systemd user service)      │  │
│   Telegram   │────┼───Internet────┼──│                               │  │
├──────────────┤    │               │  │  Port: 127.0.0.1:18789        │  │
│   Discord    │────┘               │  │  (loopback only)              │  │
├──────────────┤                    │  └───────────────────────────────┘  │
│    Slack     │                    │              │                      │
└──────────────┘                    │              ▼                      │
                                    │  ┌───────────────────────────────┐  │
                                    │  │      AI Processing            │  │
┌──────────────┐                    │  │   - Claude API calls          │  │
│  SSH Client  │────SSH Tunnel──────┼──│   - Code execution            │  │
│  (Termius)   │                    │  │   - File operations           │  │
└──────────────┘                    │  └───────────────────────────────┘  │
                                    │              │                      │
                                    │              ▼                      │
                                    │  ┌───────────────────────────────┐  │
                                    │  │      Workspace                │  │
                                    │  │   ~/.openclaw/workspace       │  │
                                    │  └───────────────────────────────┘  │
                                    └─────────────────────────────────────┘
```

---

## Prerequisites

Before installing OpenClaw, ensure you have:

1. **Completed vps-dev-setup.sh** - Base development environment
2. **NVM installed** - Node Version Manager
3. **Docker running** - Required for sandbox mode
4. **API key** - Anthropic API key for Claude

Verify prerequisites:

```bash
# Check NVM
nvm --version

# Check Node.js
node --version

# Check Docker
docker info

# Check tmux
tmux -V
```

---

## Installation

### Quick Install

```bash
# Run the OpenClaw setup script
./openclaw-setup.sh

# Source your updated bashrc
source ~/.bashrc

# Complete onboarding
openclaw onboard
```

### What Gets Installed

| Component | Location | Purpose |
|-----------|----------|---------|
| OpenClaw CLI | `npm global` | Main command-line tool |
| Configuration | `~/.openclaw/openclaw.json` | Settings and preferences |
| Workspace | `~/.openclaw/workspace` | File operations directory |
| Logs | `~/logs/openclaw/` | Application and Gateway logs |
| Service | `~/.config/systemd/user/openclaw-gateway.service` | Systemd unit file |

### Post-Installation

```bash
# Verify installation
openclaw --version

# Set your API key
openclaw config set apiKey YOUR_ANTHROPIC_API_KEY

# Start the Gateway
oc-start

# Check status
oc-check
```

---

## Configuration

### Configuration File

The main configuration file is located at `~/.openclaw/openclaw.json`.

Edit with:
```bash
oc-config    # Uses $EDITOR or nano
```

### Key Configuration Options

#### Agent Settings

```json
{
  "agent": {
    "model": "anthropic/claude-sonnet-4-5",
    "maxTokens": 8192,
    "temperature": 0.7
  }
}
```

Available models:
- `anthropic/claude-sonnet-4-5` - Fast, capable (recommended)
- `anthropic/claude-opus-4` - Most capable, slower
- `anthropic/claude-haiku-3-5` - Fastest, basic tasks

#### Gateway Settings

```json
{
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
  }
}
```

- `bind`: `"loopback"` (localhost only) or `"all"` (all interfaces - NOT recommended)
- `auth.mode`: `"password"`, `"token"`, or `"none"`
- `auth.allowTailscale`: Enable Tailscale authentication

#### Security Settings

```json
{
  "security": {
    "audit": {
      "enabled": true,
      "logPath": "~/logs/openclaw/audit.log"
    },
    "fileAccess": {
      "mode": "workspace",
      "allowPaths": ["~/.openclaw/workspace", "~/dev", "~/projects"],
      "denyPaths": ["~/.ssh", "~/.gnupg", "~/.aws", "/etc"]
    }
  }
}
```

### Environment Variables

```bash
# Add to ~/.bashrc for persistence
export ANTHROPIC_API_KEY="your-key"
export OPENCLAW_CONFIG="~/.openclaw/openclaw.json"
export OPENCLAW_LOG_LEVEL="info"
```

---

## Channel Setup

> **Security Warning**: All channels are disabled by default. Only enable channels you need, and always configure proper access controls.

### WhatsApp Setup

WhatsApp integration uses the WhatsApp Business API or a bridge service.

#### Configuration

```json
{
  "channels": {
    "whatsapp": {
      "enabled": true,
      "dm": {
        "policy": "pairing",
        "allowFrom": ["+1234567890"]
      },
      "credentials": {
        "type": "whatsapp-web-js",
        "sessionPath": "~/.openclaw/whatsapp-session"
      }
    }
  }
}
```

#### Setup Steps

1. Enable the channel in config
2. Restart Gateway: `oc-restart`
3. Scan QR code when prompted (check logs)
4. Complete pairing from your phone

```bash
# Watch for QR code in logs
oc-logs
```

#### Security Considerations

- Only add trusted phone numbers to `allowFrom`
- Use `"policy": "pairing"` to require pairing confirmation
- Consider using `"policy": "explicit"` for stricter control

### Telegram Setup

Telegram uses a bot token from @BotFather.

#### Configuration

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "dm": {
        "policy": "pairing",
        "allowFrom": ["@yourusername", "123456789"]
      },
      "credentials": {
        "botToken": "YOUR_BOT_TOKEN"
      }
    }
  }
}
```

#### Setup Steps

1. Create a bot with @BotFather on Telegram
2. Copy the bot token
3. Add token to config
4. Restart Gateway: `oc-restart`
5. Start a conversation with your bot
6. Complete pairing

```bash
# Create bot and get token
# 1. Open Telegram and search for @BotFather
# 2. Send /newbot
# 3. Follow prompts to name your bot
# 4. Copy the bot token
```

### Discord Setup

Discord requires creating a bot application.

#### Configuration

```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "dm": {
        "policy": "pairing",
        "allowFrom": ["your_discord_user_id"]
      },
      "guilds": {
        "policy": "explicit",
        "allowFrom": []
      },
      "credentials": {
        "botToken": "YOUR_DISCORD_BOT_TOKEN",
        "clientId": "YOUR_CLIENT_ID"
      }
    }
  }
}
```

#### Setup Steps

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Create a new application
3. Go to "Bot" section, create a bot
4. Copy the bot token
5. Enable "Message Content Intent" under Privileged Intents
6. Go to OAuth2 > URL Generator, select "bot" scope
7. Select permissions: Send Messages, Read Message History
8. Use generated URL to add bot to your server (if using guilds)
9. Add token and client ID to config
10. Restart Gateway: `oc-restart`

#### Finding Your Discord User ID

```bash
# Enable Developer Mode in Discord settings
# Right-click your profile > Copy User ID
```

### Slack Setup

Slack uses a bot token from a Slack App.

#### Configuration

```json
{
  "channels": {
    "slack": {
      "enabled": true,
      "dm": {
        "policy": "pairing",
        "allowFrom": ["U1234567890"]
      },
      "credentials": {
        "botToken": "xoxb-your-bot-token",
        "appToken": "xapp-your-app-token"
      }
    }
  }
}
```

#### Setup Steps

1. Go to [Slack API](https://api.slack.com/apps)
2. Create a new app
3. Add OAuth scopes: `chat:write`, `im:read`, `im:write`, `im:history`
4. Enable Socket Mode
5. Generate an App-Level Token with `connections:write` scope
6. Install to workspace
7. Copy Bot Token and App Token
8. Add to config
9. Restart Gateway: `oc-restart`

---

## Security Best Practices

### Gateway Security

1. **Always bind to loopback** (default setting)
   ```json
   "gateway": { "bind": "loopback" }
   ```

2. **Enable authentication**
   ```json
   "auth": { "mode": "password" }
   ```

3. **Enable rate limiting**
   ```json
   "rateLimit": { "enabled": true, "maxRequests": 60 }
   ```

### Channel Security

1. **Use pairing mode** for all channels
   ```json
   "dm": { "policy": "pairing" }
   ```

2. **Whitelist contacts** explicitly
   ```json
   "allowFrom": ["specific_user_id"]
   ```

3. **Disable guild/group access** unless needed
   ```json
   "guilds": { "policy": "explicit", "allowFrom": [] }
   ```

### File System Security

1. **Restrict file access**
   ```json
   "fileAccess": {
     "mode": "workspace",
     "denyPaths": ["~/.ssh", "~/.gnupg", "~/.aws", "~/.env*"]
   }
   ```

2. **Enable audit logging**
   ```json
   "audit": { "enabled": true }
   ```

### Sandbox Mode

Use sandbox mode for running untrusted commands:

```json
"agents": {
  "defaults": {
    "sandbox": {
      "mode": "non-main",
      "allowlist": ["bash", "read", "write"]
    }
  }
}
```

Sandbox modes:
- `"none"` - No sandboxing (not recommended)
- `"non-main"` - Sandbox non-main sessions
- `"all"` - Sandbox all sessions

### API Key Security

1. Never commit API keys to version control
2. Use environment variables:
   ```bash
   export ANTHROPIC_API_KEY="your-key"
   ```
3. Or use a secrets manager

---

## Remote Access

### SSH Tunnel (Recommended)

The most secure way to access your OpenClaw Gateway remotely:

```bash
# From your local machine
ssh -L 18789:127.0.0.1:18789 user@your-vps-ip

# Now access Gateway at localhost:18789
```

#### Persistent SSH Tunnel with autossh

```bash
# Install autossh
sudo apt install autossh

# Create persistent tunnel
autossh -M 0 -f -N -L 18789:127.0.0.1:18789 user@your-vps-ip
```

#### SSH Tunnel from iPhone (Termius)

1. Open Termius
2. Create a new host with your VPS details
3. Add port forwarding rule:
   - Local port: 18789
   - Remote host: 127.0.0.1
   - Remote port: 18789
4. Connect to the host

### Tailscale (Alternative)

Tailscale provides a secure mesh network:

```bash
# Install Tailscale on VPS
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# Install on your devices
# Get Tailscale IP of your VPS
tailscale ip

# Update OpenClaw config
# "auth": { "allowTailscale": true }
```

### Direct Access (NOT Recommended)

> **Warning**: Exposing the Gateway directly to the internet is a security risk.

If you must expose directly:

1. Use strong authentication
2. Enable rate limiting
3. Use UFW to restrict IP addresses
4. Consider using a reverse proxy with SSL

```bash
# UFW rule for specific IP only
sudo ufw allow from 1.2.3.4 to any port 18789

# DO NOT use:
# sudo ufw allow 18789  # This exposes to everyone!
```

---

## Workflows & Use Cases

### Workflow 1: Mobile Development Assistant

Chat with AI from your phone while coding on VPS:

```
You (WhatsApp): What files are in my current project?
OpenClaw: Running ls in ~/projects/myapp...
[lists files]

You (WhatsApp): Add error handling to the login function
OpenClaw: I'll edit src/auth/login.ts to add try-catch blocks...
[shows diff and applies changes]

You (WhatsApp): Run the tests
OpenClaw: Running npm test...
[shows test results]
```

### Workflow 2: Server Monitoring

Quick server checks from messaging apps:

```
You (Telegram): Check disk space
OpenClaw: Running df -h...
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       100G   45G   55G  45% /

You (Telegram): Show running containers
OpenClaw: Running docker ps...
[container list]
```

### Workflow 3: Code Review

Review code changes through chat:

```
You (Discord): Show me the git diff for today's changes
OpenClaw: Running git diff HEAD~5...
[displays diff]

You (Discord): Any issues with that code?
OpenClaw: I noticed a few potential improvements:
1. Missing null check on line 45
2. Consider using async/await instead of callbacks
[detailed analysis]
```

### Workflow 4: Multi-Session Work

Manage multiple projects through different sessions:

```bash
# Create project-specific sessions
openclaw sessions create --name "webapp" --workspace ~/projects/webapp
openclaw sessions create --name "api" --workspace ~/projects/api

# List sessions
openclaw sessions list

# Send command to specific session
openclaw sessions send webapp "npm run build"
```

### Workflow 5: Scheduled Tasks

Set up recurring checks:

```
You (Slack): Remind me every morning to check server health
OpenClaw: I've noted this, but cron scheduling is disabled in sandbox mode.
You can manually set up a cron job:
*/30 * * * * openclaw exec "Check server status and report"
```

---

## Troubleshooting

### Gateway Issues

#### Gateway Won't Start

```bash
# Check detailed service status
systemctl --user status openclaw-gateway

# Check for port conflicts
sudo lsof -i :18789

# Check logs
tail -100 ~/logs/openclaw/gateway-error.log

# Validate configuration
openclaw config validate
```

#### Gateway Starts But Disconnects

```bash
# Check memory usage
free -h

# Increase Node.js memory if needed
# Edit service file
nano ~/.config/systemd/user/openclaw-gateway.service
# Add: Environment=NODE_OPTIONS=--max-old-space-size=2048

# Reload and restart
systemctl --user daemon-reload
oc-restart
```

### Channel Issues

#### WhatsApp QR Code Not Showing

```bash
# Clear session and restart
rm -rf ~/.openclaw/whatsapp-session
oc-restart
oc-logs  # Watch for QR code
```

#### Telegram Bot Not Responding

1. Verify bot token is correct
2. Check bot hasn't been blocked by Telegram
3. Ensure your username/ID is in allowFrom
4. Check logs for errors

#### Discord Bot Offline

1. Verify bot token is valid
2. Check "Message Content Intent" is enabled
3. Verify bot has been added to server
4. Check for rate limiting

### Connection Issues

#### Cannot Connect to Gateway

```bash
# Test local connection
curl http://127.0.0.1:18789/health

# If using SSH tunnel, verify tunnel is active
ps aux | grep ssh

# Check Gateway is actually listening
ss -tlnp | grep 18789
```

#### Messages Not Being Processed

```bash
# Check rate limits
oc-logs | grep "rate limit"

# Check API key
openclaw config get apiKey

# Test API connectivity
openclaw test-connection
```

### Performance Issues

#### High CPU Usage

```bash
# Check what's consuming CPU
htop

# Reduce concurrent sessions
# Edit config: "agents.defaults.maxConcurrent": 2

# Enable request queuing
# Edit config: "gateway.queue.enabled": true
```

#### High Memory Usage

```bash
# Check memory
free -h

# Reduce message history
# Edit config: "agents.defaults.historyLimit": 50

# Clear old sessions
openclaw sessions cleanup --older-than 7d
```

---

## Reference

### Command Reference

```bash
# Main commands
openclaw                    # Interactive mode
openclaw chat              # Start chat session
openclaw code              # Code-focused mode
openclaw onboard           # Initial setup
openclaw config            # Configuration management
openclaw sessions          # Session management
openclaw gateway           # Gateway management

# Configuration
openclaw config get <key>
openclaw config set <key> <value>
openclaw config validate
openclaw config reset

# Sessions
openclaw sessions list
openclaw sessions create --name <name>
openclaw sessions send <name> <message>
openclaw sessions history <name>
openclaw sessions cleanup

# Gateway
openclaw gateway start
openclaw gateway stop
openclaw gateway status
```

### Alias Reference

```bash
# Main aliases
oc              # openclaw
oc-chat         # openclaw chat
oc-code         # openclaw code

# Service management
oc-start        # systemctl --user start openclaw-gateway
oc-stop         # systemctl --user stop openclaw-gateway
oc-restart      # systemctl --user restart openclaw-gateway
oc-status       # systemctl --user status openclaw-gateway
oc-enable       # systemctl --user enable openclaw-gateway
oc-disable      # systemctl --user disable openclaw-gateway

# Logs
oc-logs         # journalctl --user -u openclaw-gateway -f
oc-logs-all     # journalctl --user -u openclaw-gateway --no-pager
oc-logs-error   # tail -f ~/logs/openclaw/gateway-error.log

# Configuration
oc-config       # ${EDITOR:-nano} ~/.openclaw/openclaw.json
oc-check        # Custom status check function

# Navigation
oc-workspace    # cd ~/.openclaw/workspace
```

### File Locations

| File | Purpose |
|------|---------|
| `~/.openclaw/openclaw.json` | Main configuration |
| `~/.openclaw/workspace/` | Default workspace |
| `~/.config/systemd/user/openclaw-gateway.service` | Service definition |
| `~/logs/openclaw/openclaw.log` | Application log |
| `~/logs/openclaw/gateway.log` | Gateway stdout |
| `~/logs/openclaw/gateway-error.log` | Gateway stderr |
| `~/logs/openclaw/audit.log` | Security audit trail |

### Default Ports

| Port | Service | Binding |
|------|---------|---------|
| 18789 | Gateway API | 127.0.0.1 (loopback) |

### Links

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Security Guide](https://docs.openclaw.ai/gateway/security)
- [Channel Setup Guides](https://docs.openclaw.ai/channels)
- [API Reference](https://docs.openclaw.ai/api)

---

**Last Updated**: February 2026
**Compatible with**: OpenClaw v1.x, Node.js v22+
