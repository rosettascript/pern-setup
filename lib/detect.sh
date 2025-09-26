#!/bin/bash

# System detection and validation functions

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Detect Linux distribution
detect_linux_dist() {
    if command_exists lsb_release; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    elif [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$ID"
    elif [[ -f /etc/redhat-release ]]; then
        if grep -q "CentOS" /etc/redhat-release; then
            echo "centos"
        elif grep -q "Red Hat" /etc/redhat-release; then
            echo "rhel"
        else
            echo "redhat"
        fi
    else
        echo "unknown"
    fi
}

# Check system requirements
check_system_requirements() {
    log_info "Checking system requirements..."

    local os=$(detect_os)
    local issues=0

    case $os in
        "linux")
            check_linux_requirements
            ;;
        "macos")
            check_macos_requirements
            ;;
        "windows")
            check_windows_requirements
            ;;
        *)
            log_warning "Unsupported operating system: $os"
            issues=$((issues + 1))
            ;;
    esac

    if [[ $issues -eq 0 ]]; then
        log_success "System requirements check passed"
        return 0
    else
        log_error "System requirements check failed with $issues issues"
        return 1
    fi
}

# Check Linux-specific requirements
check_linux_requirements() {
    local dist=$(detect_linux_dist)
    log_info "Detected Linux distribution: $dist"

    # Check available disk space (at least 2GB free)
    local free_space=$(df / | tail -1 | awk '{print $4}')
    if [[ $free_space -lt 2097152 ]]; then  # 2GB in KB
        log_warning "Low disk space: $((free_space / 1024 / 1024))GB free (recommended: 2GB+)"
    fi

    # Check memory (at least 1GB RAM)
    local total_mem=$(free -m | awk 'NR==2{printf "%.0f", $2}')
    if [[ $total_mem -lt 1024 ]]; then
        log_warning "Low memory: ${total_mem}MB (recommended: 1GB+)"
    fi

    # Check if we're running as root (not recommended)
    if [[ $EUID -eq 0 ]]; then
        log_warning "Running as root - this is not recommended for development"
    fi

    # Check for package manager
    if ! command_exists apt && ! command_exists yum && ! command_exists pacman; then
        log_error "No supported package manager found (apt, yum, or pacman required)"
        return 1
    fi

    return 0
}

# Check macOS-specific requirements
check_macos_requirements() {
    log_info "Detected macOS"

    # Check macOS version
    local macos_version=$(sw_vers -productVersion)
    log_info "macOS version: $macos_version"

    # Check if Homebrew is installed
    if ! command_exists brew; then
        log_warning "Homebrew not found. Install from https://brew.sh/"
    fi

    # Check available disk space
    local free_space=$(df / | tail -1 | awk '{print $4}')
    if [[ $free_space -lt 2097152 ]]; then
        log_warning "Low disk space: $((free_space / 1024 / 1024))GB free"
    fi

    return 0
}

# Check Windows-specific requirements
check_windows_requirements() {
    log_info "Detected Windows"

    # Check if we're in WSL
    if [[ -n "$WSL_DISTRO_NAME" ]]; then
        log_info "Running in WSL: $WSL_DISTRO_NAME"
    fi

    # Check if we're in MSYS2/MinGW
    if [[ -n "$MSYS2_PATH" ]]; then
        log_info "Running in MSYS2/MinGW"
    fi

    # Check for package managers
    if command_exists choco; then
        log_info "Chocolatey package manager found"
    elif command_exists scoop; then
        log_info "Scoop package manager found"
    else
        log_warning "No package manager found. Consider installing Chocolatey or Scoop."
    fi

    return 0
}

# Check existing installations
check_existing_installations() {
    log_info "Checking existing software installations..."

    # Check Node.js
    if command_exists node; then
        local node_version=$(node --version | sed 's/v//')
        log_info "Node.js found: $node_version"
    else
        log_warning "Node.js not found"
    fi

    # Check npm
    if command_exists npm; then
        local npm_version=$(npm --version)
        log_info "npm found: $npm_version"
    else
        log_warning "npm not found"
    fi

    # Check PostgreSQL
    if command_exists psql; then
        local psql_version=$(psql --version | awk '{print $3}')
        log_info "PostgreSQL found: $psql_version"
    elif pg_isready -q 2>/dev/null; then
        log_info "PostgreSQL service is running"
    else
        log_warning "PostgreSQL not found"
    fi

    # Check Git
    if command_exists git; then
        local git_version=$(git --version | awk '{print $3}')
        log_info "Git found: $git_version"
    else
        log_warning "Git not found"
    fi

    # Check Docker (optional)
    if command_exists docker; then
        local docker_version=$(docker --version | awk '{print $3}')
        log_info "Docker found: $docker_version"
    fi

    # Check Redis (optional)
    if command_exists redis-cli; then
        local redis_version=$(redis-cli --version | awk '{print $2}')
        log_info "Redis found: $redis_version"
    fi
}

# Get recommended versions
get_recommended_versions() {
    local config_file="${SCRIPT_DIR}/../config/versions.json"
    if [[ -f "$config_file" ]]; then
        # Use jq if available, otherwise fallback to basic parsing
        if command_exists jq; then
            cat "$config_file"
        else
            log_warning "jq not found, using fallback version parsing"
            # Basic JSON parsing fallback
            sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$config_file"
        fi
    else
        # Default recommended versions
        cat << EOF
{
  "nodejs": "18.18.0",
  "npm": "9.8.1",
  "postgresql": "15.4",
  "redis": "7.2.0",
  "nodeMinimum": "16.0.0",
  "nodeMaximum": "20.0.0"
}
EOF
    fi
}

# Validate Node.js version
validate_nodejs_version() {
    local version=$1
    local min_version="16.0.0"
    local max_version="20.0.0"

    # Simple version comparison
    if [[ "$(printf '%s\n' "$min_version" "$version" | sort -V | head -n1)" != "$min_version" ]]; then
        log_error "Node.js version $version is below minimum required version $min_version"
        return 1
    fi

    if [[ "$(printf '%s\n' "$max_version" "$version" | sort -V | head -n1)" == "$max_version" ]]; then
        log_warning "Node.js version $version is above maximum recommended version $max_version"
    fi

    log_success "Node.js version $version is compatible"
    return 0
}

# Validate PostgreSQL version
validate_postgresql_version() {
    local version=$1

    # PostgreSQL 12+ is recommended
    if [[ "$(printf '%s\n' "12.0.0" "$version" | sort -V | head -n1)" != "12.0.0" ]]; then
        log_error "PostgreSQL version $version is below minimum required version 12.0.0"
        return 1
    fi

    log_success "PostgreSQL version $version is compatible"
    return 0
}

# Check port availability
check_port_available() {
    local port=$1
    local service_name=${2:-"service"}

    if command_exists netstat; then
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            log_warning "Port $port is already in use (might conflict with $service_name)"
            return 1
        fi
    elif command_exists ss; then
        if ss -tuln 2>/dev/null | grep -q ":$port "; then
            log_warning "Port $port is already in use (might conflict with $service_name)"
            return 1
        fi
    fi

    log_success "Port $port is available for $service_name"
    return 0
}

# Check firewall status
check_firewall() {
    local os=$(detect_os)

    case $os in
        "linux")
            if command_exists ufw; then
                if ufw status | grep -q "active"; then
                    log_info "UFW firewall is active"
                else
                    log_info "UFW firewall is inactive"
                fi
            elif command_exists firewall-cmd; then
                if firewall-cmd --state 2>/dev/null | grep -q "running"; then
                    log_info "firewalld is active"
                else
                    log_info "firewalld is inactive"
                fi
            fi
            ;;
        "macos")
            if command_exists /usr/libexec/ApplicationFirewall/socketfilterfw; then
                local firewall_status=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null || echo "unknown")
                log_info "macOS firewall status: $firewall_status"
            fi
            ;;
    esac
}

# Display system information
display_system_info() {
    log_info "=== System Information ==="
    echo "Operating System: $(detect_os)"
    echo "Architecture: $(uname -m)"
    echo "Kernel Version: $(uname -r)"
    echo "Shell: $SHELL"
    echo "Current User: $USER"
    echo "Working Directory: $(pwd)"
    echo "Script Directory: $SCRIPT_DIR"
    echo

    # Display disk usage
    log_info "=== Disk Usage ==="
    df -h /
    echo

    # Display memory usage
    log_info "=== Memory Usage ==="
    free -h 2>/dev/null || echo "Memory information not available"
    echo
}

# Pre-flight checks
run_preflight_checks() {
    log_info "Running pre-flight checks..."

    # Check if we're in a supported environment
    local os=$(detect_os)
    if [[ "$os" == "unknown" ]]; then
        log_error "Unsupported operating system"
        return 1
    fi

    # Check system requirements
    if ! check_system_requirements; then
        log_error "System requirements not met"
        return 1
    fi

    # Check existing installations
    check_existing_installations

    # Check port availability for common services
    check_port_available 3000 "React development server"
    check_port_available 5000 "Express.js server"
    check_port_available 5432 "PostgreSQL"
    check_port_available 6379 "Redis"

    # Check firewall
    check_firewall

    log_success "Pre-flight checks completed"
    return 0
}