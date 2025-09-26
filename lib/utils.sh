#!/bin/bash

# Utility functions for PERN Stack Setup

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# Print functions
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_step() {
    echo -e "${YELLOW}Step $1: $2${NC}"
}

# Input validation functions
validate_project_name() {
    local name=$1
    if [[ -z "$name" ]]; then
        log_error "Project name cannot be empty"
        return 1
    fi

    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "Project name can only contain letters, numbers, hyphens, and underscores"
        return 1
    fi

    return 0
}

validate_path() {
    local path=$1
    if [[ -z "$path" ]]; then
        log_error "Path cannot be empty"
        return 1
    fi

    # Check if path is absolute or relative
    if [[ "$path" != /* ]]; then
        path="$(cd "$(dirname "$0")" && pwd)/$path"
    fi

    echo "$path"
    return 0
}

# File and directory operations
create_directory() {
    local dir=$1
    if [[ ! -d "$dir" ]]; then
        if mkdir -p "$dir"; then
            log_success "Created directory: $dir"
            return 0
        else
            log_error "Failed to create directory: $dir"
            return 1
        fi
    else
        log_info "Directory already exists: $dir"
        return 0
    fi
}

create_file() {
    local file=$1
    local content=$2

    if [[ -f "$file" ]]; then
        log_warning "File already exists: $file"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping file creation"
            return 0
        fi
    fi

    if echo "$content" > "$file"; then
        log_success "Created file: $file"
        return 0
    else
        log_error "Failed to create file: $file"
        return 1
    fi
}

# Git operations
initialize_git() {
    local project_path=$1
    cd "$project_path"

    if [[ ! -d ".git" ]]; then
        if git init; then
            log_success "Initialized Git repository"
            return 0
        else
            log_error "Failed to initialize Git repository"
            return 1
        fi
    else
        log_info "Git repository already exists"
        return 0
    fi
}

create_gitignore() {
    local project_path=$1
    local template=$2
    cd "$project_path"

    local gitignore_content=""
    case $template in
        "node")
            gitignore_content="node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
dist/
build/
*.log
.DS_Store"
            ;;
        "react")
            gitignore_content="node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
dist/
build/
*.log
.DS_Store
coverage/
.nyc_output"
            ;;
        "fullstack")
            gitignore_content="node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
dist/
build/
*.log
.DS_Store
coverage/
.nyc_output
postgres-data/
*.pem
ssl/"
            ;;
    esac

    if create_file ".gitignore" "$gitignore_content"; then
        return 0
    else
        return 1
    fi
}

# Package.json operations
create_package_json() {
    local project_path=$1
    local name=$2
    local type=$3
    cd "$project_path"

    local package_json='{
  "name": "'$name'",
  "version": "0.1.0",
  "description": "PERN Stack Application",
  "main": "server/index.js",
  "scripts": {
    "start": "node server/index.js",
    "dev": "nodemon server/index.js",
    "build": "npm run build:client && npm run build:server",
    "build:client": "cd client && npm run build",
    "build:server": "cd server && npm run build",
    "test": "npm run test:client && npm run test:server",
    "test:client": "cd client && npm test",
    "test:server": "cd server && npm test"
  },
  "keywords": ["pern", "postgresql", "express", "react", "nodejs"],
  "author": "",
  "license": "MIT"
}'

    if create_file "package.json" "$package_json"; then
        return 0
    else
        return 1
    fi
}

# Random string generation
generate_random_string() {
    local length=${1:-32}
    openssl rand -base64 $length | tr -d "=+/" | cut -c1-$length
}

# Password strength validation
validate_password() {
    local password=$1
    local min_length=${2:-8}

    if [[ ${#password} -lt $min_length ]]; then
        log_error "Password must be at least $min_length characters long"
        return 1
    fi

    if ! [[ "$password" =~ [A-Z] ]]; then
        log_error "Password must contain at least one uppercase letter"
        return 1
    fi

    if ! [[ "$password" =~ [a-z] ]]; then
        log_error "Password must contain at least one lowercase letter"
        return 1
    fi

    if ! [[ "$password" =~ [0-9] ]]; then
        log_error "Password must contain at least one number"
        return 1
    fi

    return 0
}

# Progress indicator
show_progress() {
    local current=$1
    local total=$2
    local message=$3

    local percentage=$((current * 100 / total))
    local progress=$((current * 50 / total))

    printf "\r${BLUE}[INFO]${NC} $message ["
    for ((i=1; i<=progress; i++)); do printf "="; done
    for ((i=progress+1; i<=50; i++)); do printf " "; done
    printf "] %d%% (%d/%d)" $percentage $current $total
}

# Enhanced progress indicator with time estimation
show_progress_with_time() {
    local current=$1
    local total=$2
    local message=$3
    local start_time=$4

    local percentage=$((current * 100 / total))
    local progress=$((current * 50 / total))
    local elapsed=$(($(date +%s) - start_time))
    local estimated_total=$((elapsed * total / current))
    local remaining=$((estimated_total - elapsed))

    printf "\r${BLUE}[INFO]${NC} $message ["
    for ((i=1; i<=progress; i++)); do printf "="; done
    for ((i=progress+1; i<=50; i++)); do printf " "; done
    printf "] %d%% (%d/%d) ETA: %ds" $percentage $current $total $remaining
}

# Checkpoint system for error recovery
create_checkpoint() {
    local checkpoint_name=$1
    local checkpoint_file="/tmp/pern-setup-checkpoint-${checkpoint_name}"
    
    echo "$(date +%s)" > "$checkpoint_file"
    log_info "Checkpoint created: $checkpoint_name"
}

# Remove checkpoint
remove_checkpoint() {
    local checkpoint_name=$1
    local checkpoint_file="/tmp/pern-setup-checkpoint-${checkpoint_name}"
    
    if [[ -f "$checkpoint_file" ]]; then
        rm -f "$checkpoint_file"
        log_info "Checkpoint removed: $checkpoint_name"
    fi
}

# Check if checkpoint exists
checkpoint_exists() {
    local checkpoint_name=$1
    local checkpoint_file="/tmp/pern-setup-checkpoint-${checkpoint_name}"
    
    [[ -f "$checkpoint_file" ]]
}

# Get checkpoint time
get_checkpoint_time() {
    local checkpoint_name=$1
    local checkpoint_file="/tmp/pern-setup-checkpoint-${checkpoint_name}"
    
    if [[ -f "$checkpoint_file" ]]; then
        cat "$checkpoint_file"
    else
        echo "0"
    fi
}

# Rollback function
rollback_setup() {
    local checkpoint_name=$1
    log_warning "Rolling back to checkpoint: $checkpoint_name"
    
    case $checkpoint_name in
        "project_created")
            if [[ -n "$PROJECT_PATH" && -d "$PROJECT_PATH" ]]; then
                log_info "Removing project directory: $PROJECT_PATH"
                rm -rf "$PROJECT_PATH"
            fi
            ;;
        "dependencies_installed")
            if [[ -n "$PROJECT_PATH" && -d "$PROJECT_PATH" ]]; then
                log_info "Removing node_modules and package-lock.json"
                rm -rf "$PROJECT_PATH/node_modules"
                rm -f "$PROJECT_PATH/package-lock.json"
                if [[ -d "$PROJECT_PATH/server" ]]; then
                    rm -rf "$PROJECT_PATH/server/node_modules"
                    rm -f "$PROJECT_PATH/server/package-lock.json"
                fi
                if [[ -d "$PROJECT_PATH/client" ]]; then
                    rm -rf "$PROJECT_PATH/client/node_modules"
                    rm -f "$PROJECT_PATH/client/package-lock.json"
                fi
            fi
            ;;
        "database_configured")
            log_info "Database configuration will need manual cleanup"
            ;;
    esac
    
    remove_checkpoint "$checkpoint_name"
}

# Load package configuration
load_package_config() {
    local template_type=$1
    local component=$2
    local config_file="$SCRIPT_DIR/../config/packages.json"
    
    if [[ -f "$config_file" ]]; then
        if command_exists jq; then
            jq -r ".$template_type.$component" "$config_file" 2>/dev/null
        else
            # Fallback parsing for systems without jq
            grep -A 20 "\"$template_type\"" "$config_file" | grep -A 20 "\"$component\"" | grep -E "^\s*\"" | sed 's/.*"\([^"]*\)": "\([^"]*\)".*/\1:\2/' | head -20
        fi
    fi
}

# Install packages from configuration
install_packages_from_config() {
    local template_type=$1
    local component=$2
    local project_path=$3
    local dependency_type=${4:-"dependencies"}
    
    log_info "Installing $component packages for $template_type template..."
    
    # Get package configuration
    local packages=$(load_package_config "$template_type" "$component")
    
    if [[ -n "$packages" ]]; then
        cd "$project_path/$component"
        
        # Install packages
        local package_list=""
        while IFS= read -r line; do
            if [[ "$line" =~ ^[a-zA-Z0-9_-]+: ]]; then
                local package_name=$(echo "$line" | cut -d: -f1)
                local package_version=$(echo "$line" | cut -d: -f2)
                package_list="$package_list $package_name@$package_version"
            fi
        done <<< "$packages"
        
        if [[ -n "$package_list" ]]; then
            if [[ "$dependency_type" == "devDependencies" ]]; then
                npm install --save-dev $package_list
            else
                npm install --save $package_list
            fi
        fi
    fi
}

# Enhanced cleanup function
cleanup() {
    log_info "Cleaning up temporary files..."
    
    # Remove checkpoints
    rm -f /tmp/pern-setup-checkpoint-*
    
    # Remove temporary files
    rm -f /tmp/pern-setup-*
    
    # Clean up any background processes
    if [[ -n "$SERVER_PID" ]] && kill -0 $SERVER_PID 2>/dev/null; then
        kill $SERVER_PID 2>/dev/null
    fi
    
    if [[ -n "$CLIENT_PID" ]] && kill -0 $CLIENT_PID 2>/dev/null; then
        kill $CLIENT_PID 2>/dev/null
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if package is installed
package_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Get user confirmation
confirm() {
    local message=$1
    local default=${2:-"n"}

    if [[ $default == "y" ]]; then
        read -p "$message [Y/n]: " -n 1 -r
        echo
        [[ $REPLY =~ ^[Nn]$ ]] && return 1 || return 0
    else
        read -p "$message [y/N]: " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && return 0 || return 1
    fi
}

# Get user input with validation
get_input() {
    local prompt=$1
    local validation_func=$2
    local default_value=$3

    while true; do
        if [[ -n "$default_value" ]]; then
            read -p "$prompt [$default_value]: " input
            input=${input:-$default_value}
        else
            read -p "$prompt: " input
        fi

        if [[ -n "$validation_func" ]]; then
            if $validation_func "$input"; then
                echo "$input"
                break
            fi
        else
            echo "$input"
            break
        fi
    done
}

# Backup existing file
backup_file() {
    local file=$1
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        if cp "$file" "$backup"; then
            log_info "Backed up $file to $backup"
            return 0
        else
            log_error "Failed to backup $file"
            return 1
        fi
    fi
    return 0
}