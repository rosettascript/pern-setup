#!/bin/bash

# Installation functions for PERN Stack Setup

# Quick setup with recommended versions
quick_setup() {
    log_info "Starting quick setup with recommended versions..."

    # Get recommended versions
    local versions=$(get_recommended_versions)
    local node_version=$(echo "$versions" | grep -o '"nodejs": "[^"]*"' | cut -d'"' -f4)
    local postgres_version=$(echo "$versions" | grep -o '"postgresql": "[^"]*"' | cut -d'"' -f4)

    log_info "Recommended versions: Node.js $node_version, PostgreSQL $postgres_version"

    # Install Node.js
    if ! command_exists node; then
        log_info "Installing Node.js $node_version..."
        install_nodejs "$node_version"
    else
        local current_version=$(node --version | sed 's/v//')
        log_info "Node.js already installed: $current_version"
        if ! confirm "Update Node.js to $node_version?"; then
            log_info "Keeping existing Node.js version"
        else
            install_nodejs "$node_version"
        fi
    fi

    # Install PostgreSQL
    if ! command_exists psql; then
        log_info "Installing PostgreSQL $postgres_version..."
        install_postgresql "$postgres_version"
    else
        log_info "PostgreSQL already installed"
        if ! confirm "Reinstall PostgreSQL?"; then
            log_info "Keeping existing PostgreSQL installation"
        else
            install_postgresql "$postgres_version"
        fi
    fi

    # Install Redis (optional)
    if ! command_exists redis-cli; then
        if confirm "Install Redis for caching/sessions?"; then
            install_redis
        fi
    fi

    log_success "Quick setup completed"
}

# Custom setup with user-specified versions
custom_setup() {
    log_info "Starting custom setup..."

    # Get user preferences for versions
    local node_version=$(get_input "Node.js version" "" "18.18.0")
    local postgres_version=$(get_input "PostgreSQL version" "" "15.4")

    # Install Node.js
    if ! command_exists node; then
        log_info "Installing Node.js $node_version..."
        install_nodejs "$node_version"
    else
        local current_version=$(node --version | sed 's/v//')
        log_info "Node.js already installed: $current_version"
        if confirm "Update to Node.js $node_version?"; then
            install_nodejs "$node_version"
        fi
    fi

    # Install PostgreSQL
    if ! command_exists psql; then
        log_info "Installing PostgreSQL $postgres_version..."
        install_postgresql "$postgres_version"
    else
        log_info "PostgreSQL already installed"
        if confirm "Reinstall PostgreSQL $postgres_version?"; then
            install_postgresql "$postgres_version"
        fi
    fi

    # Optional installations
    if confirm "Install Redis for caching/sessions?"; then
        install_redis
    fi

    if confirm "Install Docker for containerized development?"; then
        install_docker
    fi

    log_success "Custom setup completed"
}

# Interactive step-by-step setup
interactive_setup() {
    log_info "Starting interactive step-by-step setup..."

    # Run pre-flight checks
    if ! run_preflight_checks; then
        if ! confirm "Continue despite pre-flight check failures?"; then
            log_info "Setup cancelled"
            return 0
        fi
    fi

    # Interactive installation process
    local os=$(detect_os)

    case $os in
        "linux")
            interactive_linux_setup
            ;;
        "macos")
            interactive_macos_setup
            ;;
        "windows")
            interactive_windows_setup
            ;;
        *)
            log_error "Unsupported OS for interactive setup"
            return 1
            ;;
    esac
}

# Interactive Linux setup
interactive_linux_setup() {
    local dist=$(detect_linux_dist)

    case $dist in
        "ubuntu"|"debian")
            install_ubuntu_packages
            ;;
        "centos"|"rhel"|"fedora")
            install_redhat_packages
            ;;
        "arch"|"manjaro")
            install_arch_packages
            ;;
        *)
            log_warning "Unsupported Linux distribution: $dist"
            manual_installation_guide
            ;;
    esac
}

# Interactive macOS setup
interactive_macos_setup() {
    if ! command_exists brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Install packages via Homebrew
    local packages=("node" "postgresql" "redis")
    for package in "${packages[@]}"; do
        if ! command_exists $package; then
            if confirm "Install $package via Homebrew?"; then
                brew install $package
            fi
        fi
    done
}

# Interactive Windows setup
interactive_windows_setup() {
    log_info "Windows setup guide:"

    if command_exists choco; then
        log_info "Using Chocolatey package manager..."
        local packages=("nodejs" "postgresql" "redis")
        for package in "${packages[@]}"; do
            if ! command_exists $package; then
                if confirm "Install $package via Chocolatey?"; then
                    choco install $package -y
                fi
            fi
        done
    elif command_exists scoop; then
        log_info "Using Scoop package manager..."
        scoop install nodejs postgresql redis
    else
        log_info "Please install the following manually:"
        echo "1. Node.js from https://nodejs.org/"
        echo "2. PostgreSQL from https://postgresql.org/"
        echo "3. Redis from https://redis.io/"
    fi
}

# Node.js installation
install_nodejs() {
    local version=$1
    local os=$(detect_os)

    case $os in
        "linux")
            install_nodejs_linux "$version"
            ;;
        "macos")
            install_nodejs_macos "$version"
            ;;
        "windows")
            install_nodejs_windows "$version"
            ;;
        *)
            log_error "Unsupported OS for Node.js installation"
            return 1
            ;;
    esac
}

# Node.js installation on Linux
install_nodejs_linux() {
    local version=$1
    local dist=$(detect_linux_dist)

    case $dist in
        "ubuntu"|"debian")
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        "centos"|"rhel"|"fedora")
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
            sudo yum install -y nodejs
            ;;
        "arch"|"manjaro")
            sudo pacman -S nodejs npm
            ;;
        *)
            log_warning "Using generic Node.js installation"
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm install "$version"
            nvm use "$version"
            ;;
    esac

    # Verify installation
    if command_exists node; then
        local installed_version=$(node --version | sed 's/v//')
        log_success "Node.js $installed_version installed successfully"
    else
        log_error "Node.js installation failed"
        return 1
    fi
}

# Node.js installation on macOS
install_nodejs_macos() {
    local version=$1

    if command_exists brew; then
        brew install node@$version
        brew link node@$version
    else
        log_error "Homebrew not found. Please install Homebrew first."
        return 1
    fi
}

# Node.js installation on Windows
install_nodejs_windows() {
    local version=$1

    if command_exists choco; then
        choco install nodejs --version=$version -y
    elif command_exists scoop; then
        scoop install nodejs@$version
    else
        log_error "Please install Node.js manually from https://nodejs.org/"
        return 1
    fi
}

# PostgreSQL installation
install_postgresql() {
    local version=$1
    local os=$(detect_os)

    case $os in
        "linux")
            install_postgresql_linux "$version"
            ;;
        "macos")
            install_postgresql_macos "$version"
            ;;
        "windows")
            install_postgresql_windows "$version"
            ;;
        *)
            log_error "Unsupported OS for PostgreSQL installation"
            return 1
            ;;
    esac
}

# PostgreSQL installation on Linux
install_postgresql_linux() {
    local version=$1
    local dist=$(detect_linux_dist)

    case $dist in
        "ubuntu"|"debian")
            sudo apt-get update
            # Use available PostgreSQL version instead of specific version
            sudo apt-get install -y postgresql postgresql-contrib
            sudo systemctl enable postgresql
            sudo systemctl start postgresql
            ;;
        "centos"|"rhel"|"fedora")
            sudo yum install -y postgresql-server postgresql-contrib
            sudo postgresql-setup initdb
            sudo systemctl enable postgresql
            sudo systemctl start postgresql
            ;;
        "arch"|"manjaro")
            sudo pacman -S postgresql
            sudo su - postgres -c "initdb --locale en_US.UTF-8 -D /var/lib/postgres/data"
            sudo systemctl enable postgresql
            sudo systemctl start postgresql
            ;;
    esac

    # Verify installation
    if command_exists psql; then
        log_success "PostgreSQL installed successfully"
        create_database_user
    else
        log_error "PostgreSQL installation failed"
        return 1
    fi
}

# PostgreSQL installation on macOS
install_postgresql_macos() {
    local version=$1

    if command_exists brew; then
        brew install postgresql@$version
        brew link postgresql@$version
        brew services start postgresql@$version
    else
        log_error "Homebrew not found. Please install Homebrew first."
        return 1
    fi
}

# PostgreSQL installation on Windows
install_postgresql_windows() {
    local version=$1

    if command_exists choco; then
        choco install postgresql --version=$version -y
    else
        log_error "Please install PostgreSQL manually from https://postgresql.org/"
        return 1
    fi
}

# Redis installation
install_redis() {
    local os=$(detect_os)

    case $os in
        "linux")
            install_redis_linux
            ;;
        "macos")
            install_redis_macos
            ;;
        "windows")
            install_redis_windows
            ;;
        *)
            log_error "Unsupported OS for Redis installation"
            return 1
            ;;
    esac
}

# Redis installation on Linux
install_redis_linux() {
    local dist=$(detect_linux_dist)

    case $dist in
        "ubuntu"|"debian")
            sudo apt-get install -y redis-server
            sudo systemctl enable redis-server
            sudo systemctl start redis-server
            ;;
        "centos"|"rhel"|"fedora")
            sudo yum install -y redis
            sudo systemctl enable redis
            sudo systemctl start redis
            ;;
        "arch"|"manjaro")
            sudo pacman -S redis
            sudo systemctl enable redis
            sudo systemctl start redis
            ;;
    esac

    # Verify installation
    if command_exists redis-cli; then
        log_success "Redis installed successfully"
    else
        log_error "Redis installation failed"
        return 1
    fi
}

# Redis installation on macOS
install_redis_macos() {
    if command_exists brew; then
        brew install redis
        brew services start redis
    else
        log_error "Homebrew not found. Please install Homebrew first."
        return 1
    fi
}

# Redis installation on Windows
install_redis_windows() {
    if command_exists choco; then
        choco install redis-64 -y
    elif command_exists scoop; then
        scoop install redis
    else
        log_error "Please install Redis manually from https://redis.io/"
        return 1
    fi
}

# Docker installation
install_docker() {
    local os=$(detect_os)

    case $os in
        "linux")
            install_docker_linux
            ;;
        "macos")
            install_docker_macos
            ;;
        "windows")
            install_docker_windows
            ;;
        *)
            log_error "Unsupported OS for Docker installation"
            return 1
            ;;
    esac
}

# Docker installation on Linux
install_docker_linux() {
    local dist=$(detect_linux_dist)

    case $dist in
        "ubuntu"|"debian")
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            sudo usermod -aG docker $USER
            ;;
        "centos"|"rhel"|"fedora")
            sudo yum install -y docker
            sudo systemctl enable docker
            sudo systemctl start docker
            sudo usermod -aG docker $USER
            ;;
        "arch"|"manjaro")
            sudo pacman -S docker
            sudo systemctl enable docker
            sudo systemctl start docker
            sudo usermod -aG docker $USER
            ;;
    esac

    log_success "Docker installed. Please log out and back in for group changes to take effect."
}

# Docker installation on macOS
install_docker_macos() {
    if command_exists brew; then
        brew install --cask docker
        log_info "Docker installed. Please start Docker Desktop from Applications."
    else
        log_error "Homebrew not found. Please install Homebrew first."
        return 1
    fi
}

# Docker installation on Windows
install_docker_windows() {
    if command_exists choco; then
        choco install docker-desktop -y
    else
        log_error "Please install Docker Desktop manually from https://docker.com/desktop"
        return 1
    fi
}

# Create database user and database
create_database_user() {
    log_info "Setting up PostgreSQL user and database..."

    # Generate random password
    DB_PASSWORD=$(generate_random_string 16)

    # Create user and database
    sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';" 2>/dev/null || true
    sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" 2>/dev/null || true
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" 2>/dev/null || true

    log_success "Database user '$DB_USER' and database '$DB_NAME' created"
}

# Manual installation guide
manual_installation_guide() {
    log_info "=== Manual Installation Guide ==="
    echo "Please install the following software manually:"
    echo
    echo "1. Node.js (LTS version recommended):"
    echo "   - Download from: https://nodejs.org/"
    echo "   - Or use nvm: https://github.com/nvm-sh/nvm"
    echo
    echo "2. PostgreSQL:"
    echo "   - Download from: https://postgresql.org/"
    echo "   - Or use Docker: docker run --name postgres -e POSTGRES_PASSWORD=... -d -p 5432:5432 postgres"
    echo
    echo "3. Redis (optional):"
    echo "   - Download from: https://redis.io/"
    echo "   - Or use Docker: docker run --name redis -d -p 6379:6379 redis"
    echo
    echo "4. Git:"
    echo "   - Usually pre-installed on most systems"
    echo "   - Download from: https://git-scm.com/"
    echo
}

# Package installation for Ubuntu/Debian
install_ubuntu_packages() {
    log_info "Installing packages for Ubuntu/Debian..."

    sudo apt-get update

    # Install essential build tools
    sudo apt-get install -y build-essential curl git

    # Install Node.js
    if ! command_exists node; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi

    # Install PostgreSQL
    if ! command_exists psql; then
        sudo apt-get install -y postgresql postgresql-contrib
        sudo systemctl enable postgresql
        sudo systemctl start postgresql
    fi

    # Install Redis
    if ! command_exists redis-cli; then
        sudo apt-get install -y redis-server
        sudo systemctl enable redis-server
        sudo systemctl start redis-server
    fi
}

# Package installation for Red Hat/CentOS/Fedora
install_redhat_packages() {
    log_info "Installing packages for Red Hat/CentOS/Fedora..."

    # Install essential build tools
    sudo yum groupinstall -y "Development Tools"
    sudo yum install -y curl git

    # Install Node.js
    if ! command_exists node; then
        curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
        sudo yum install -y nodejs
    fi

    # Install PostgreSQL
    if ! command_exists psql; then
        sudo yum install -y postgresql-server postgresql-contrib
        sudo postgresql-setup initdb
        sudo systemctl enable postgresql
        sudo systemctl start postgresql
    fi

    # Install Redis
    if ! command_exists redis-cli; then
        sudo yum install -y redis
        sudo systemctl enable redis
        sudo systemctl start redis
    fi
}

# Package installation for Arch Linux
install_arch_packages() {
    log_info "Installing packages for Arch Linux..."

    # Install packages
    sudo pacman -S --needed base-devel curl git nodejs npm postgresql redis

    # Enable and start services
    sudo systemctl enable postgresql redis
    sudo systemctl start postgresql redis
}