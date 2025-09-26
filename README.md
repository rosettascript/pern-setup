# 🚀 PERN Setup v1.0.0

**The fastest way to create production-ready PERN Stack applications**

PERN Setup is a powerful, cross-platform boilerplate generator that creates modern PostgreSQL + Express.js + React + Node.js applications in minutes. Choose from 5 professional templates, get security best practices built-in, and start coding with confidence.

> **🎯 Perfect for:** Full-stack developers, startups, students, and teams building modern web applications with the PERN stack (PostgreSQL, Express.js, React, Node.js).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-16%2B-green.svg)](https://nodejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5%2B-blue.svg)](https://www.typescriptlang.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED.svg)](https://www.docker.com/)

> **⚡ One Command Setup** • **🔒 Security First** • **📱 Cross-Platform** • **🐳 Docker Ready** • **🧪 Testing Included**

## ✨ Why PERN Setup?

- **🚀 Lightning Fast**: Create a complete PERN Stack app in under 2 minutes
- **🔒 Production Ready**: Security best practices, JWT auth, rate limiting built-in
- **📱 Cross-Platform**: Works on Linux, macOS, Windows (PowerShell & WSL2)
- **🎯 5 Professional Templates**: From simple APIs to microservices architectures
- **🛠️ Modern Dev Tools**: TypeScript, ESLint, Prettier, Jest, Docker, CI/CD ready
- **📚 Zero Learning Curve**: Comprehensive docs and examples included
- **🔧 Customizable**: Choose your own stack components and configurations

## 🚀 Quick Start

### For Linux/macOS Users
```bash
# Clone the repository
git clone https://github.com/rosettascript/pern-setup.git
cd pern-setup

# Make the script executable
chmod +x run.sh

# Run the setup
./run.sh
```

### For Windows Users
```powershell
# Clone the repository
git clone https://github.com/rosettascript/pern-setup.git
cd pern-setup

# Run the PowerShell script
.\run.ps1
```

## 📋 System Requirements

### Operating System Compatibility

| Operating System | Shell Script | PowerShell Script | Recommended |
|------------------|--------------|-------------------|-------------|
| **Linux** | ✅ Fully Supported | ❌ Not Available | Bash Script |
| **macOS** | ✅ Fully Supported | ❌ Not Available | Bash Script |
| **Windows (WSL2)** | ✅ Fully Supported | ❌ Not Available | Bash Script |
| **Windows (Git Bash)** | ✅ Mostly Supported | ❌ Not Available | Bash Script |
| **Windows (PowerShell)** | ❌ Not Supported | ✅ Fully Supported | PowerShell Script |
| **Windows (Command Prompt)** | ❌ Not Supported | ❌ Not Supported | Use WSL2 or PowerShell |

### Prerequisites

#### For All Systems:
- **Node.js** 16+ (recommended: 18 LTS)
- **npm** 8+ or **yarn** 1.22+
- **Git** 2.20+
- **PostgreSQL** 12+ (optional, can be installed via script)

#### For Windows Users:
- **PowerShell 5.1+** or **PowerShell Core 6+**
- **Windows 10/11** (recommended)
- **WSL2** (for Bash script compatibility)

#### For Linux Users:
- **Ubuntu 18.04+**, **Debian 10+**, **CentOS 7+**, **RHEL 7+**, **Fedora 30+**
- **Package manager**: `apt`, `yum`, or `dnf`

#### For macOS Users:
- **macOS 10.15+** (Catalina or later)
- **Homebrew** (recommended for package management)

## 🛠️ Installation Options

### Option 1: Quick Setup (Recommended)
```bash
# Linux/macOS
./run.sh

# Windows PowerShell
.\run.ps1
```

### Option 2: Custom Setup
Choose specific versions and configurations for your project.

### Option 3: Interactive Step-by-Step
Get guided through each step of the setup process.

## 📁 Project Templates

### 1. Starter Template
- Modern React + Express with TypeScript
- Basic authentication
- File upload support
- Modern UI components

### 2. API-Only Template
- Express.js backend with comprehensive setup
- Database integration
- Authentication middleware
- API documentation

### 3. Full-Stack Template
- Complete application with frontend and backend
- Authentication system
- File upload functionality
- Modern UI with Tailwind CSS

### 4. Microservices Template
- Multi-service architecture
- API Gateway
- Service discovery
- Docker containerization

### 5. Custom Structure
- Interactive folder creation
- Choose your own components
- Flexible configuration

## 🔧 Features

### Development Tools
- **Code Quality**: ESLint, Prettier, EditorConfig
- **Testing**: Jest, Supertest, React Testing Library
- **Git Hooks**: Husky, lint-staged
- **Docker**: Dockerfile, docker-compose.yml
- **CI/CD**: GitHub Actions, GitLab CI templates

### Database Support
- **PostgreSQL** with automatic setup
- **Redis** for caching and sessions
- **Database migrations**
- **Connection pooling**
- **Environment-based configuration**

### Security Features
- **JWT authentication**
- **Password hashing**
- **CORS configuration**
- **Rate limiting**
- **Security headers**
- **SSL/TLS certificates**

## 📖 Usage Examples

### Basic Full-Stack Setup
```bash
# Run the script
./run.sh

# Choose option 3 (Full-stack template)
# Follow the prompts to configure your project
```

### Windows PowerShell Setup
```powershell
# Run the PowerShell script
.\run.ps1

# Choose your template and follow the setup wizard
```

### Custom Configuration
```bash
# Set environment variables before running
export PROJECT_NAME="my-pern-app"
export DB_PASSWORD="secure-password"

# Run with custom settings
./run.sh
```

## 🔍 Troubleshooting

### Common Issues

#### Permission Denied (Linux/macOS)
```bash
# Fix script permissions
chmod +x run.sh
chmod +x lib/*.sh
```

#### PowerShell Execution Policy (Windows)
```powershell
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or run with bypass
.\run.ps1 -ExecutionPolicy Bypass
```

#### Node.js Not Found
```bash
# Install Node.js via package manager
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS (with Homebrew)
brew install node

# Windows (with Chocolatey)
choco install nodejs
```

#### PostgreSQL Connection Issues
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Start PostgreSQL
sudo systemctl start postgresql

# Check connection
psql -h localhost -U postgres
```

### Platform-Specific Notes

#### Windows Users
- **WSL2**: Best compatibility with Bash script
- **PowerShell**: Use `run.ps1` for native Windows experience
- **Git Bash**: Limited compatibility, some features may not work

#### Linux Users
- **Ubuntu/Debian**: Full support with `apt` package manager
- **CentOS/RHEL**: Full support with `yum`/`dnf` package manager
- **Arch Linux**: Manual installation may be required

#### macOS Users
- **Homebrew**: Recommended for package management
- **Xcode Command Line Tools**: Required for some dependencies

## 📚 Documentation

### Project Structure
```
pern-setup/
├── run.sh              # Main setup script (Linux/macOS)
├── run.ps1             # PowerShell script (Windows)
├── lib/                # Library functions
│   ├── utils.sh        # Utility functions
│   ├── detect.sh       # System detection
│   ├── install.sh      # Installation functions
│   ├── database.sh      # Database setup
│   ├── security.sh     # Security configuration
│   ├── devtools.sh     # Development tools
│   └── validator.sh     # Validation functions
├── templates/          # Project templates
│   ├── starter/        # Starter template
│   ├── fullstack/      # Full-stack template
│   ├── api-only/       # API-only template
│   └── microservices/  # Microservices template
└── docs/              # Documentation
```

### Environment Variables
```bash
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=myuser
DB_PASSWORD=mypassword

# Application Configuration
NODE_ENV=development
PORT=5000
JWT_SECRET=your-secret-key
CORS_ORIGIN=http://localhost:3000
```

## ❓ Frequently Asked Questions

### **What is PERN Stack?**
PERN Stack is a popular full-stack development combination using:
- **PostgreSQL** - Robust relational database
- **Express.js** - Fast, unopinionated web framework for Node.js
- **React** - JavaScript library for building user interfaces
- **Node.js** - JavaScript runtime for server-side development

### **How is PERN Setup different from other boilerplates?**
- **⚡ Speed**: 2-minute setup vs hours of manual configuration
- **🔒 Security**: Production-ready security features built-in
- **📱 Cross-platform**: Works on Linux, macOS, and Windows
- **🎯 Templates**: 5 specialized templates for different use cases
- **🛠️ Modern Tools**: Latest TypeScript, testing, and development tools

### **Do I need prior PERN Stack experience?**
No! PERN Setup is designed for both beginners and experienced developers. The comprehensive documentation and examples make it easy to get started.

### **Can I customize the generated project?**
Absolutely! All templates are fully customizable. You can modify any component, add new features, or remove what you don't need.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple platforms
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Copyright (c) 2025 Kim Galicia**

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/rosettascript/pern-setup/issues)
- **Discussions**: [GitHub Discussions](https://github.com/rosettascript/pern-setup/discussions)
- **Documentation**: [Wiki](https://github.com/rosettascript/pern-setup/wiki)

## 🔄 Changelog

### v1.0.0
- Added PowerShell support for Windows users
- Enhanced cross-platform compatibility
- Improved template structure
- Added comprehensive documentation
- Fixed fullstack template file inclusion issues

### v1.0.0
- Initial release
- Bash script for Linux/macOS
- Basic project templates
- Database setup automation

---

**Made with ❤️ for the PERN Stack community**