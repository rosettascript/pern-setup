# Cross-Platform Compatibility Guide

This document provides detailed information about operating system compatibility for the PERN Stack Setup script.

## 🖥️ Operating System Support Matrix

| Platform | Bash Script | PowerShell Script | Package Managers | Notes |
|----------|-------------|-------------------|------------------|-------|
| **Linux (Ubuntu/Debian)** | ✅ Full | ❌ N/A | apt, snap | Recommended |
| **Linux (CentOS/RHEL)** | ✅ Full | ❌ N/A | yum, dnf | Recommended |
| **Linux (Arch/Manjaro)** | ✅ Full | ❌ N/A | pacman, AUR | Manual setup may be needed |
| **macOS (Intel)** | ✅ Full | ❌ N/A | Homebrew, MacPorts | Recommended |
| **macOS (Apple Silicon)** | ✅ Full | ❌ N/A | Homebrew | Recommended |
| **Windows 10/11 (WSL2)** | ✅ Full | ❌ N/A | apt (Ubuntu) | **Best Option** |
| **Windows 10/11 (Git Bash)** | ⚠️ Limited | ❌ N/A | N/A | Some features may not work |
| **Windows 10/11 (PowerShell)** | ❌ No | ✅ Full | Chocolatey, Scoop | **Native Windows** |
| **Windows 10/11 (CMD)** | ❌ No | ❌ No | N/A | Not supported |

## 🔧 Platform-Specific Setup Instructions

### Linux Users

#### Ubuntu/Debian
```bash
# Update package list
sudo apt update

# Install prerequisites
sudo apt install -y curl git build-essential

# Install Node.js (via NodeSource)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Run the setup script
./run.sh
```

#### CentOS/RHEL/Fedora
```bash
# Install prerequisites
sudo yum install -y curl git gcc gcc-c++ make

# Install Node.js (via NodeSource)
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install PostgreSQL
sudo yum install -y postgresql-server postgresql-contrib

# Run the setup script
./run.sh
```

### macOS Users

#### With Homebrew (Recommended)
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install prerequisites
brew install node postgresql git

# Run the setup script
./run.sh
```

#### With MacPorts
```bash
# Install Node.js
sudo port install nodejs18

# Install PostgreSQL
sudo port install postgresql15

# Run the setup script
./run.sh
```

### Windows Users

#### Option 1: WSL2 (Recommended)
```bash
# Install WSL2 with Ubuntu
wsl --install

# After WSL2 is installed, open Ubuntu terminal and run:
sudo apt update
sudo apt install -y curl git build-essential
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs postgresql

# Clone and run the script
git clone https://github.com/rosettascript/pern-setup.git
cd pern-setup
./run.sh
```

#### Option 2: PowerShell (Native Windows)
```powershell
# Install Chocolatey (if not already installed)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install prerequisites
choco install nodejs postgresql git -y

# Clone and run the PowerShell script
git clone https://github.com/rosettascript/pern-setup.git
cd pern-setup
.\run.ps1
```

#### Option 3: Git Bash (Limited Support)
```bash
# Install Git for Windows (includes Git Bash)
# Download from: https://git-scm.com/download/win

# Install Node.js manually
# Download from: https://nodejs.org/

# Install PostgreSQL manually
# Download from: https://www.postgresql.org/download/windows/

# Run the script (some features may not work)
./run.sh
```

## 🐛 Known Issues and Solutions

### Windows-Specific Issues

#### PowerShell Execution Policy
**Problem**: Script execution is blocked by PowerShell policy.
**Solution**:
```powershell
# Set execution policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or run with bypass
.\run.ps1 -ExecutionPolicy Bypass
```

#### Path Length Limitations
**Problem**: Windows has path length limitations that may cause issues.
**Solution**: Use shorter project names and paths, or enable long path support:
```powershell
# Enable long path support (requires admin)
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
```

#### Line Ending Issues
**Problem**: Git may convert line endings, causing script issues.
**Solution**:
```bash
# Configure Git to handle line endings properly
git config --global core.autocrlf input
```

### Linux-Specific Issues

#### Permission Denied
**Problem**: Script lacks execute permissions.
**Solution**:
```bash
chmod +x run.sh
chmod +x lib/*.sh
```

#### Missing Dependencies
**Problem**: Required packages not installed.
**Solution**:
```bash
# Ubuntu/Debian
sudo apt install -y build-essential curl git

# CentOS/RHEL
sudo yum groupinstall -y "Development Tools"
sudo yum install -y curl git
```

### macOS-Specific Issues

#### Xcode Command Line Tools
**Problem**: Missing development tools.
**Solution**:
```bash
# Install Xcode Command Line Tools
xcode-select --install
```

#### Homebrew Permission Issues
**Problem**: Homebrew installation fails due to permissions.
**Solution**:
```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /usr/local/share/zsh /usr/local/share/zsh/site-functions
```

## 🔍 Compatibility Testing

### Tested Configurations

#### Linux
- ✅ Ubuntu 20.04 LTS
- ✅ Ubuntu 22.04 LTS
- ✅ Debian 11
- ✅ CentOS 8
- ✅ RHEL 8
- ✅ Fedora 36
- ✅ Arch Linux (manual setup required)

#### macOS
- ✅ macOS Big Sur (11.x)
- ✅ macOS Monterey (12.x)
- ✅ macOS Ventura (13.x)
- ✅ macOS Sonoma (14.x)
- ✅ Intel Macs
- ✅ Apple Silicon Macs (M1/M2)

#### Windows
- ✅ Windows 10 (WSL2)
- ✅ Windows 11 (WSL2)
- ✅ Windows 10 (PowerShell 5.1)
- ✅ Windows 11 (PowerShell 7.x)
- ⚠️ Windows 10 (Git Bash) - Limited support
- ❌ Windows 10 (Command Prompt) - Not supported

## 🚀 Performance Considerations

### Recommended System Requirements

#### Minimum Requirements
- **RAM**: 4GB
- **Storage**: 10GB free space
- **CPU**: 2 cores
- **Network**: Internet connection for package downloads

#### Recommended Requirements
- **RAM**: 8GB+
- **Storage**: 20GB+ free space
- **CPU**: 4+ cores
- **Network**: Fast internet connection

### Platform-Specific Performance Notes

#### Linux
- **Best Performance**: Native Linux installation
- **Package Managers**: `apt` (fastest), `yum`/`dnf` (good), `pacman` (fast)
- **Docker**: Excellent support

#### macOS
- **Best Performance**: Native macOS with Homebrew
- **Package Managers**: Homebrew (recommended), MacPorts (alternative)
- **Docker**: Good support

#### Windows
- **Best Performance**: WSL2 with Ubuntu
- **Package Managers**: Chocolatey (good), Scoop (fast)
- **Docker**: Good support with Docker Desktop

## 📞 Getting Help

### Platform-Specific Support

#### Linux Issues
- Check system logs: `journalctl -xe`
- Verify package manager: `which apt` or `which yum`
- Test Node.js: `node --version`

#### macOS Issues
- Check Homebrew: `brew doctor`
- Verify Xcode tools: `xcode-select -p`
- Test Node.js: `node --version`

#### Windows Issues
- Check PowerShell version: `$PSVersionTable`
- Verify WSL2: `wsl --list --verbose`
- Test Node.js: `node --version`

### Community Support
- **GitHub Issues**: Report platform-specific issues
- **Discussions**: Ask questions about compatibility
- **Wiki**: Check platform-specific documentation

## 🔄 Migration Between Platforms

### From Windows to Linux/macOS
1. Export your project from Windows
2. Transfer files to Linux/macOS system
3. Run the setup script on the new platform
4. Update any Windows-specific configurations

### From Linux/macOS to Windows
1. Use WSL2 for best compatibility
2. Or use the PowerShell script for native Windows experience
3. Update any Unix-specific configurations

### Cross-Platform Development
- Use Docker for consistent environments
- Use Node.js version managers (nvm, n)
- Use cross-platform package managers (npm, yarn)
- Test on multiple platforms regularly

---

**Note**: This compatibility guide is regularly updated. Check the latest version for the most current information.

