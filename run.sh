#!/bin/bash

# PERN Stack Setup Script v2.0.0
# Comprehensive setup for PostgreSQL, Express.js, React, Node.js development environment
# Enhanced with modern folder structure and best practices

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME=""
PROJECT_PATH=""
DB_NAME=""
DB_USER=""
DB_PASSWORD=""
DB_HOST="localhost"
DB_PORT="5432"
SKIP_DB=false
MULTI_ENV=false
SAMPLE_DATA=false
MIGRATIONS=false
REDIS=false

# Source library scripts
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/detect.sh"
source "${SCRIPT_DIR}/lib/install.sh"
source "${SCRIPT_DIR}/lib/database.sh"
source "${SCRIPT_DIR}/lib/security.sh"
source "${SCRIPT_DIR}/lib/devtools.sh"
source "${SCRIPT_DIR}/lib/validator.sh"

# Function to set permissions for all scripts
set_script_permissions() {
    local project_path="$1"
    
    log_info "Setting executable permissions for all scripts..."
    
    # Find and set permissions for all shell scripts
    find "$project_path" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    # Set permissions for specific script directories
    if [[ -d "$project_path/scripts" ]]; then
        find "$project_path/scripts" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
        find "$project_path/scripts" -type f -name "*.py" -exec chmod +x {} \; 2>/dev/null || true
        find "$project_path/scripts" -type f -name "*.js" -exec chmod +x {} \; 2>/dev/null || true
    fi
    
    # Set permissions for Docker scripts
    if [[ -d "$project_path/docker" ]]; then
        find "$project_path/docker" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    fi
    
    # Set permissions for server scripts
    if [[ -d "$project_path/server/scripts" ]]; then
        find "$project_path/server/scripts" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
        find "$project_path/server/scripts" -name "*.js" -type f -exec chmod +x {} \; 2>/dev/null || true
    fi
    
    # Set permissions for client scripts
    if [[ -d "$project_path/client/scripts" ]]; then
        find "$project_path/client/scripts" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    fi
    
    # Set permissions for any other common script locations
    find "$project_path" -path "*/bin/*" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    find "$project_path" -path "*/tools/*" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    log_success "Script permissions set successfully"
}

# Function to fix permissions for existing projects
fix_existing_project_permissions() {
    echo -e "${BLUE}=== Fix Script Permissions ===${NC}"
    echo "This will set executable permissions for all scripts in your project."
    echo
    
    # Get project path
    local project_path
    project_path=$(get_input "Enter project path" "" "$(pwd)")
    
    if [[ ! -d "$project_path" ]]; then
        log_error "Project path does not exist: $project_path"
        return 1
    fi
    
    log_info "Fixing permissions for project: $project_path"
    
    # Set permissions
    set_script_permissions "$project_path"
    
    echo
    log_success "All script permissions have been fixed!"
    echo "You can now run your scripts without permission errors."
}

# Main menu function
show_main_menu() {
    echo -e "${BLUE}=== PERN Stack Setup ===${NC}"
    echo "Choose an option:"
    echo "1) Quick setup (recommended versions)"
    echo "2) Custom setup (choose specific versions)"
    echo "3) Check existing installations"
    echo "4) Interactive step-by-step"
    echo "5) Fix script permissions (for existing projects)"
    echo "6) Exit"
    echo
}

# Project structure menu
show_project_menu() {
    echo -e "${BLUE}=== Project Structure & Templates ===${NC}"
    echo "Choose a template:"
    echo "1) Starter template (modern React + Express with TypeScript)"
    echo "2) API-only template (Express.js backend with comprehensive setup)"
    echo "3) Full-stack template (complete app with auth, file upload, modern UI)"
    echo "4) Microservices template (multi-service architecture with Docker)"
    echo "5) Custom structure (interactive folder creation)"
    echo "6) Exit"
    echo
}

# Database setup menu
show_database_menu() {
    echo -e "${BLUE}=== Database Setup ===${NC}"
    echo "Choose database option:"
    echo "1) Local PostgreSQL (auto-config with random secure credentials)"
    echo "2) Local PostgreSQL (custom config - user provides details)"
    echo "3) Docker PostgreSQL (containerized setup)"
    echo "4) Remote database (provide connection string)"
    echo "5) Skip database setup"
    echo "6) Exit"
    echo
}

# Environment menu
show_environment_menu() {
    echo -e "${BLUE}=== Environment & Security ===${NC}"
    echo "Choose configuration option:"
    echo "1) Auto-generate secure configuration (JWT secrets, API keys)"
    echo "2) Configure CORS settings (development/production modes)"
    echo "3) Set up SSL/TLS (development certificates)"
    echo "4) Configure logging levels (debug, info, warn, error)"
    echo "5) Custom security setup (interactive)"
    echo "6) Skip configuration"
    echo
}

# Development tools menu
show_devtools_menu() {
    echo -e "${BLUE}=== Development Tools (Optional) ===${NC}"
    echo "Choose development tools:"
    echo "1) Code quality tools (ESLint + Prettier + EditorConfig)"
    echo "2) Testing framework (Jest + Supertest + React Testing Library)"
    echo "3) Git hooks (Husky + lint-staged)"
    echo "4) Docker support (Dockerfile + docker-compose.yml)"
    echo "5) CI/CD templates (GitHub Actions / GitLab CI)"
    echo "6) Skip dev tools"
    echo
}

# Final validation menu
show_validation_menu() {
    echo -e "${BLUE}=== Final Configuration & Validation ===${NC}"
    echo "Choose final step:"
    echo "1) Install dependencies (npm install for all components)"
    echo "2) Validate setup (test all connections and services)"
    echo "3) Run initial build (ensure everything compiles)"
    echo "4) Skip validation"
    echo
}

# Summary menu
show_summary_menu() {
    echo -e "${BLUE}=== Installation Summary ===${NC}"
    echo "What would you like to do next?"
    echo "1) Start development servers (backend + frontend)"
    echo "2) Open project in VS Code (if available)"
    echo "3) Show project documentation"
    echo "4) Exit"
    echo
}

# Get user choice
get_choice() {
    local max_choice=$1
    local choice

    while true; do
        read -p "Enter your choice (1-${max_choice}): " choice
        if [[ $choice =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max_choice" ]; then
            echo $choice
            break
        else
            echo -e "${RED}Invalid choice. Please enter a number between 1 and ${max_choice}.${NC}"
        fi
    done
}

# Main execution function
main() {
    echo -e "${GREEN}Welcome to PERN Stack Setup v2.0.0!${NC}"
    echo "This script will help you set up a complete PERN (PostgreSQL, Express.js, React, Node.js) development environment."
    echo -e "${BLUE}New in v2.0.0: Modern folder structure, TypeScript support, enhanced templates, and improved development experience!${NC}"
    echo

    # Step 1: Installation Options
    echo -e "${YELLOW}Step 1: Enhanced Installation Options${NC}"
    show_main_menu
    choice=$(get_choice 6)

    case $choice in
        1)
            echo -e "${GREEN}Running quick setup with recommended versions...${NC}"
            quick_setup
            ;;
        2)
            echo -e "${GREEN}Running custom setup...${NC}"
            custom_setup
            ;;
        3)
            echo -e "${GREEN}Checking existing installations...${NC}"
            check_installations
            return
            ;;
        4)
            echo -e "${GREEN}Running interactive step-by-step setup...${NC}"
            interactive_setup
            return
            ;;
        5)
            echo -e "${GREEN}Fixing script permissions...${NC}"
            fix_existing_project_permissions
            return
            ;;
        6)
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
    esac

    # Step 2: Project Structure
    echo -e "${YELLOW}Step 2: Project Structure & Templates${NC}"
    show_project_menu
    choice=$(get_choice 6)

    case $choice in
        1)
            setup_starter_template
            ;;
        2)
            setup_api_only_template
            ;;
        3)
            setup_fullstack_template
            ;;
        4)
            setup_microservices_template
            ;;
        5)
            setup_custom_structure
            ;;
        6)
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
    esac

    # Step 3: Database Setup
    if [ "$SKIP_DB" = false ]; then
        echo -e "${YELLOW}Step 3: Database Setup${NC}"
        show_database_menu
        choice=$(get_choice 6)

        case $choice in
            1)
                setup_auto_database
                ;;
            2)
                setup_custom_database
                ;;
            3)
                setup_docker_database
                ;;
            4)
                setup_remote_database
                ;;
            5)
                SKIP_DB=true
                echo -e "${YELLOW}Skipping database setup...${NC}"
                ;;
            6)
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
        esac
    fi

    # Step 4: Environment & Security
    echo -e "${YELLOW}Step 4: Environment & Security${NC}"
    show_environment_menu
    choice=$(get_choice 6)

    case $choice in
        1)
            generate_secure_config
            ;;
        2)
            configure_cors
            ;;
        3)
            setup_ssl
            ;;
        4)
            configure_logging
            ;;
        5)
            custom_security_setup
            ;;
        6)
            echo -e "${YELLOW}Skipping environment configuration...${NC}"
            ;;
    esac

    # Step 5: Development Tools
    echo -e "${YELLOW}Step 5: Development Tools (Optional)${NC}"
    show_devtools_menu
    choice=$(get_choice 6)

    case $choice in
        1)
            setup_code_quality_tools
            ;;
        2)
            setup_testing_framework
            ;;
        3)
            setup_git_hooks
            ;;
        4)
            setup_docker_support
            ;;
        5)
            setup_ci_cd_templates
            ;;
        6)
            echo -e "${YELLOW}Skipping development tools...${NC}"
            ;;
    esac

    # Step 6: Final Validation
    echo -e "${YELLOW}Step 6: Final Configuration & Validation${NC}"
    show_validation_menu
    choice=$(get_choice 4)

    case $choice in
        1)
            install_dependencies
            ;;
        2)
            validate_setup
            ;;
        3)
            run_initial_build
            ;;
        4)
            echo -e "${YELLOW}Skipping validation...${NC}"
            ;;
    esac

    # Final Summary
    echo -e "${GREEN}=== Installation Complete! ===${NC}"
    show_installation_summary

    show_summary_menu
    choice=$(get_choice 4)

    case $choice in
        1)
            start_development_servers
            ;;
        2)
            open_in_vscode
            ;;
        3)
            show_documentation
            ;;
        4)
            echo -e "${GREEN}Setup complete! Happy coding!${NC}"
            exit 0
            ;;
    esac
}

# Template setup functions
setup_starter_template() {
    log_info "Setting up starter template..."
    
    # Get project details
    PROJECT_NAME=$(get_input "Project name" validate_project_name "pern-starter")
    PROJECT_PATH=$(get_input "Project path" "" "$HOME/Projects/$PROJECT_NAME")
    
    # Create checkpoint
    create_checkpoint "project_created"
    
    # Create project directory
    create_directory "$PROJECT_PATH"
    cd "$PROJECT_PATH"
    
    # Copy starter template
    log_info "Copying starter template files..."
    cp -r "$SCRIPT_DIR/templates/starter/"* "$PROJECT_PATH/"
    
    # Initialize Git repository
    if confirm "Initialize Git repository?" "y"; then
        initialize_git "$PROJECT_PATH"
        create_gitignore "$PROJECT_PATH" "fullstack"
    fi
    
    # Create environment file
    create_database_env
    
    # Install dependencies with progress
    log_info "Installing dependencies..."
    local start_time=$(date +%s)
    show_progress_with_time 1 3 "Installing dependencies" $start_time
    
    if install_dependencies; then
        show_progress_with_time 2 3 "Dependencies installed" $start_time
        create_checkpoint "dependencies_installed"
    else
        log_error "Failed to install dependencies"
        rollback_setup "project_created"
        return 1
    fi
    
    show_progress_with_time 3 3 "Setup completed" $start_time
    echo # New line after progress bar
    
    remove_checkpoint "project_created"
    remove_checkpoint "dependencies_installed"
    
    # Set script permissions
    set_script_permissions "$PROJECT_PATH"
    
    log_success "Starter template setup completed"
}

setup_api_only_template() {
    log_info "Setting up API-only template..."
    
    # Get project details
    PROJECT_NAME=$(get_input "Project name" validate_project_name "pern-api")
    PROJECT_PATH=$(get_input "Project path" "" "$HOME/Projects/$PROJECT_NAME")
    
    # Create project directory
    create_directory "$PROJECT_PATH"
    cd "$PROJECT_PATH"
    
    # Create API-only structure
    create_directory "$PROJECT_PATH/server"
    create_directory "$PROJECT_PATH/server/routes"
    create_directory "$PROJECT_PATH/server/controllers"
    create_directory "$PROJECT_PATH/server/middleware"
    create_directory "$PROJECT_PATH/server/models"
    create_directory "$PROJECT_PATH/server/config"
    create_directory "$PROJECT_PATH/server/tests"
    create_directory "$PROJECT_PATH/docs"
    
    # Create server package.json
    local server_package="$PROJECT_PATH/server/package.json"
    cat > "$server_package" << EOF
{
  "name": "$PROJECT_NAME-server",
  "version": "0.1.0",
  "description": "PERN API Server",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  },
  "keywords": ["api", "express", "postgresql", "nodejs"],
  "author": "",
  "license": "MIT"
}
EOF

    # Create main server file
    local server_index="$PROJECT_PATH/server/index.js"
    cat > "$server_index" << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Logging
app.use(morgan('combined'));

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api', (req, res) => {
  res.json({ 
    message: 'Welcome to PERN API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      api: '/api'
    }
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

    # Create root package.json
    create_package_json "$PROJECT_PATH" "$PROJECT_NAME" "api-only"
    
    # Initialize Git repository
    if confirm "Initialize Git repository?" "y"; then
        initialize_git "$PROJECT_PATH"
        create_gitignore "$PROJECT_PATH" "node"
    fi
    
    # Create environment file
    create_database_env
    
    # Install dependencies
    install_dependencies
    
    # Set script permissions
    set_script_permissions "$PROJECT_PATH"
    
    log_success "API-only template setup completed"
}

setup_fullstack_template() {
    log_info "Setting up fullstack template..."
    
    # Get project details
    PROJECT_NAME=$(get_input "Project name" validate_project_name "pern-fullstack")
    PROJECT_PATH=$(get_input "Project path" "" "$HOME/Projects/$PROJECT_NAME")
    
    # Create project directory
    create_directory "$PROJECT_PATH"
    cd "$PROJECT_PATH"
    
    # Copy fullstack template files
    log_info "Copying fullstack template files..."
    cp -r "$SCRIPT_DIR/templates/fullstack/"* "$PROJECT_PATH/"
    
    # Initialize Git repository
    if confirm "Initialize Git repository?" "y"; then
        initialize_git "$PROJECT_PATH"
        create_gitignore "$PROJECT_PATH" "fullstack"
    fi
    
    # Run template setup script to create environment files
    if [[ -f "$PROJECT_PATH/scripts/setup.sh" ]]; then
        log_info "Running template setup script..."
        chmod +x "$PROJECT_PATH/scripts/setup.sh"
        "$PROJECT_PATH/scripts/setup.sh"
    else
        # Fallback: Create environment file
        create_database_env
    fi
    
    # Install dependencies
    install_dependencies
    
    # Set script permissions
    set_script_permissions "$PROJECT_PATH"
    
    log_success "Fullstack template setup completed"
}

setup_microservices_template() {
    log_info "Setting up microservices template..."
    
    # Get project details
    PROJECT_NAME=$(get_input "Project name" validate_project_name "pern-microservices")
    PROJECT_PATH=$(get_input "Project path" "" "$HOME/Projects/$PROJECT_NAME")
    
    # Create project directory
    create_directory "$PROJECT_PATH"
    cd "$PROJECT_PATH"
    
    # Copy microservices template files
    log_info "Copying microservices template files..."
    cp -r "$SCRIPT_DIR/templates/microservices/"* "$PROJECT_PATH/"
    
    # Initialize Git repository
    if confirm "Initialize Git repository?" "y"; then
        initialize_git "$PROJECT_PATH"
        create_gitignore "$PROJECT_PATH" "fullstack"
    fi
    
    # Run template setup script to create environment files
    if [[ -f "$PROJECT_PATH/scripts/setup.sh" ]]; then
        log_info "Running template setup script..."
        chmod +x "$PROJECT_PATH/scripts/setup.sh"
        "$PROJECT_PATH/scripts/setup.sh"
    else
        # Fallback: Create environment file
        create_database_env
    fi
    
    # Install dependencies
    install_dependencies
    
    # Set script permissions
    set_script_permissions "$PROJECT_PATH"
    
    log_success "Microservices template setup completed"
}

setup_custom_structure() {
    log_info "Setting up custom structure..."
    
    # Get project details
    PROJECT_NAME=$(get_input "Project name" validate_project_name "pern-custom")
    PROJECT_PATH=$(get_input "Project path" "" "$HOME/Projects/$PROJECT_NAME")
    
    # Create project directory
    create_directory "$PROJECT_PATH"
    cd "$PROJECT_PATH"
    
    # Interactive structure creation
    log_info "Let's create your custom project structure..."
    
    # Ask for components
    local has_server=false
    local has_client=false
    local has_database=false
    local has_docker=false
    local has_tests=false
    
    if confirm "Include server/backend?" "y"; then
        has_server=true
        create_directory "$PROJECT_PATH/server"
    fi
    
    if confirm "Include client/frontend?" "y"; then
        has_client=true
        create_directory "$PROJECT_PATH/client"
    fi
    
    if confirm "Include database setup?" "y"; then
        has_database=true
    fi
    
    if confirm "Include Docker support?" "n"; then
        has_docker=true
        create_directory "$PROJECT_PATH/docker"
    fi
    
    if confirm "Include testing setup?" "y"; then
        has_tests=true
        create_directory "$PROJECT_PATH/tests"
    fi
    
    # Create additional directories
    if confirm "Create docs directory?" "y"; then
        create_directory "$PROJECT_PATH/docs"
    fi
    
    if confirm "Create scripts directory?" "y"; then
        create_directory "$PROJECT_PATH/scripts"
    fi
    
    # Create package.json based on selections
    local package_type="custom"
    if [[ "$has_server" == "true" && "$has_client" == "true" ]]; then
        package_type="fullstack"
    elif [[ "$has_server" == "true" ]]; then
        package_type="api-only"
    fi
    
    create_package_json "$PROJECT_PATH" "$PROJECT_NAME" "$package_type"
    
    # Initialize Git repository
    if confirm "Initialize Git repository?" "y"; then
        initialize_git "$PROJECT_PATH"
        create_gitignore "$PROJECT_PATH" "$package_type"
    fi
    
    # Create environment file if database is included
    if [[ "$has_database" == "true" ]]; then
        create_database_env
    fi
    
    # Install dependencies
    install_dependencies
    
    # Set script permissions
    set_script_permissions "$PROJECT_PATH"
    
    log_success "Custom structure setup completed"
}

# Trap to handle cleanup on exit
trap cleanup EXIT

# Run main function
main "$@"