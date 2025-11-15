# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Home Manager configuration repository for managing a NixOS/Linux user's personal development environment using the Nix ecosystem. It focuses on AI-assisted development workflows with multiple AI providers and comprehensive development tools.

## Key Commands

### Home Manager Operations
```bash
# Apply configuration changes (alias: hms)
home-manager switch

# Build configuration without switching
home-manager build

# Update flake inputs
nix flake update

# Check flake outputs
nix flake show
```

### Secrets Management
```bash
# Encrypt new secrets (requires age public key)
nix-shell -p agenix --run "agenix -e secrets/[filename].age"

# Decrypt and view secrets
nix-shell -p agenix --run "agenix -d secrets/[filename].age"
```

### Development Tools
```bash
# AI CLI tools (all configured with proper API keys)
claude              # Claude Code (Anthropic)
glm                 # GLM/BigModel API wrapper
ds-cli              # DeepSeek API wrapper
kimi                # Kimi API wrapper
aichat              # AI chat interface (configured for DeepSeek)

# Common development aliases
lg                  # lazygit
ai                  # aichat
```

## Architecture & Structure

### Configuration Files
- `flake.nix` - Main Nix flake defining inputs (nixpkgs, home-manager, agenix) and system configuration
- `home.nix` - Primary Home Manager configuration with packages, programs, and user settings
- `age.nix` - Age encryption configuration for secrets management
- `secrets/secrets.nix` - Public key configuration for age encryption

### AI Integration Architecture
The repository implements a sophisticated AI provider abstraction using shell script wrappers:

1. **Claude Code Integration**: Primary AI tool with environment-based configuration
2. **Custom AI Wrappers**: `glm`, `ds-cli`, `kimi` - Each wrapper sets specific API endpoints and models
3. **AIChat Configuration**: Unified interface for DeepSeek with function calling support
4. **Secret Management**: API tokens stored encrypted with age, decrypted at runtime

### Key Design Patterns
- **Wrapper Pattern**: Custom shell scripts (`claude_alt` function) that configure environment variables before calling base tools
- **Age Encryption**: All API tokens encrypted with SSH-based age keys
- **Flake-based Reproducibility**: All dependencies pinned through flake.lock
- **Environment Variable Injection**: API keys loaded from encrypted secrets into environment variables

### Package Categories
- **AI Tools**: claude-code, gemini-cli, aichat, custom wrappers
- **Development**: ast-grep, cmake, cppman, neovim, rustup, zig, go
- **Terminal**: lazygit, lazydocker, yazi, zellij, zoxide, starship
- **Languages**: nodejs, pnpm, uv (Python), typst

## Important Notes

- Always use `home-manager switch` to apply changes
- Secrets are managed through age encryption - never commit unencrypted tokens
- The system uses nixpkgs-unstable for latest packages
- All AI tools are pre-configured with their respective API endpoints and models
- Environment variables are injected at shell initialization from encrypted secrets