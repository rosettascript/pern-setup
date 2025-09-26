#!/bin/bash

# Setup validation and testing functions

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."

    # Check if package.json exists
    if [[ ! -f "$PROJECT_PATH/package.json" ]]; then
        log_error "package.json not found. Cannot install dependencies."
        return 1
    fi

    # Install server dependencies
    if [[ -d "$PROJECT_PATH/server" ]]; then
        log_info "Installing server dependencies..."
        cd "$PROJECT_PATH/server"
        if [[ -f "package.json" ]]; then
            npm install
        else
            log_warning "Server package.json not found"
        fi
    fi

    # Install client dependencies
    if [[ -d "$PROJECT_PATH/client" ]]; then
        log_info "Installing client dependencies..."
        cd "$PROJECT_PATH/client"
        if [[ -f "package.json" ]]; then
            npm install
        else
            log_warning "Client package.json not found"
        fi
    fi

    # Install root dependencies
    cd "$PROJECT_PATH"
    if [[ -f "package.json" ]]; then
        npm install
    fi

    log_success "Dependencies installed successfully"
}

# Validate setup
validate_setup() {
    log_info "Validating setup..."

    local validation_results=()
    local errors=0

    # Validate project structure
    if validate_project_structure; then
        validation_results+=("✅ Project structure is valid")
    else
        validation_results+=("❌ Project structure validation failed")
        errors=$((errors + 1))
    fi

    # Validate environment configuration
    if validate_environment; then
        validation_results+=("✅ Environment configuration is valid")
    else
        validation_results+=("❌ Environment configuration validation failed")
        errors=$((errors + 1))
    fi

    # Validate database connection
    if [[ "$SKIP_DB" == "false" ]]; then
        if validate_database_connection; then
            validation_results+=("✅ Database connection is working")
        else
            validation_results+=("❌ Database connection failed")
            errors=$((errors + 1))
        fi
    else
        validation_results+=("⏭️  Database setup was skipped")
    fi

    # Validate services
    if validate_services; then
        validation_results+=("✅ Services are running correctly")
    else
        validation_results+=("❌ Service validation failed")
        errors=$((errors + 1))
    fi

    # Display validation results
    log_info "=== Validation Results ==="
    for result in "${validation_results[@]}"; do
        echo "$result"
    done

    if [[ $errors -eq 0 ]]; then
        log_success "All validations passed!"
        return 0
    else
        log_error "Validation failed with $errors errors"
        return 1
    fi
}

# Run initial build
run_initial_build() {
    log_info "Running initial build..."

    # Build server
    if [[ -d "$PROJECT_PATH/server" ]]; then
        log_info "Building server..."
        cd "$PROJECT_PATH/server"
        if [[ -f "package.json" ]]; then
            npm run build 2>/dev/null || log_warning "Server build failed or not configured"
        fi
    fi

    # Build client
    if [[ -d "$PROJECT_PATH/client" ]]; then
        log_info "Building client..."
        cd "$PROJECT_PATH/client"
        if [[ -f "package.json" ]]; then
            npm run build 2>/dev/null || log_warning "Client build failed or not configured"
        fi
    fi

    # Build root
    cd "$PROJECT_PATH"
    if [[ -f "package.json" ]]; then
        npm run build 2>/dev/null || log_warning "Root build failed or not configured"
    fi

    log_success "Initial build completed"
}

# Validate project structure
validate_project_structure() {
    log_info "Validating project structure..."

    local structure_valid=true

    # Check for essential files
    local essential_files=(
        "package.json"
        ".env"
        ".gitignore"
    )

    for file in "${essential_files[@]}"; do
        if [[ ! -f "$PROJECT_PATH/$file" ]]; then
            log_warning "Missing essential file: $file"
            structure_valid=false
        fi
    done

    # Check for server directory
    if [[ ! -d "$PROJECT_PATH/server" ]]; then
        log_warning "Missing server directory"
        structure_valid=false
    else
        # Check for server files
        local server_files=(
            "server/package.json"
            "server/app.js"
            "server/index.js"
        )

        for file in "${server_files[@]}"; do
            if [[ ! -f "$PROJECT_PATH/$file" ]]; then
                log_info "Optional server file missing: $file"
            fi
        done
    fi

    # Check for client directory (if it's a full-stack app)
    if [[ -d "$PROJECT_PATH/client" ]]; then
        local client_files=(
            "client/package.json"
            "client/public/index.html"
            "client/src/index.js"
            "client/src/App.js"
        )

        for file in "${client_files[@]}"; do
            if [[ ! -f "$PROJECT_PATH/$file" ]]; then
                log_info "Optional client file missing: $file"
            fi
        done
    fi

    return $structure_valid
}

# Validate environment configuration
validate_environment() {
    log_info "Validating environment configuration..."

    local env_valid=true

    # Check .env file
    if [[ -f "$PROJECT_PATH/.env" ]]; then
        # Check for required environment variables
        local required_vars=(
            "NODE_ENV"
            "PORT"
            "DB_HOST"
            "DB_PORT"
            "DB_NAME"
            "DB_USER"
            "JWT_SECRET"
        )

        for var in "${required_vars[@]}"; do
            if ! grep -q "^$var=" "$PROJECT_PATH/.env"; then
                log_warning "Missing environment variable: $var"
                env_valid=false
            fi
        done

        # Check for sensitive data in .env
        if grep -q "password\|secret\|key" "$PROJECT_PATH/.env" | grep -v "=" | head -3; then
            log_warning "Sensitive data found in .env file"
        fi
    else
        log_error ".env file not found"
        env_valid=false
    fi

    # Check .env.example file
    if [[ ! -f "$PROJECT_PATH/.env.example" ]]; then
        log_info ".env.example file not found (optional)"
    fi

    return $env_valid
}

# Validate database connection
validate_database_connection() {
    log_info "Validating database connection..."

    # Test connection using different methods
    if test_database_connection; then
        return 0
    fi

    # Try using Node.js test script
    local test_script=$(mktemp)
    cat > "$test_script" << EOF
const { Client } = require('pg');

async function testConnection() {
  const client = new Client({
    host: process.env.DB_HOST || '$DB_HOST',
    port: process.env.DB_PORT || $DB_PORT,
    database: process.env.DB_NAME || '$DB_NAME',
    user: process.env.DB_USER || '$DB_USER',
    password: process.env.DB_PASSWORD || '$DB_PASSWORD'
  });

  try {
    await client.connect();
    console.log('Database connection successful');
    await client.end();
    process.exit(0);
  } catch (error) {
    console.error('Database connection failed:', error.message);
    process.exit(1);
  }
}

testConnection();
EOF

    cd "$PROJECT_PATH"
    if [[ -f ".env" ]]; then
        # Load environment variables
        set -a
        source .env
        set +a
    fi

    if node "$test_script" 2>/dev/null; then
        rm -f "$test_script"
        return 0
    fi

    rm -f "$test_script"
    return 1
}

# Validate services
validate_services() {
    log_info "Validating services..."

    local services_valid=true

    # Check if Node.js is working
    if command_exists node; then
        local node_version=$(node --version)
        log_info "Node.js version: $node_version"
    else
        log_error "Node.js not found"
        services_valid=false
    fi

    # Check if npm is working
    if command_exists npm; then
        local npm_version=$(npm --version)
        log_info "npm version: $npm_version"
    else
        log_error "npm not found"
        services_valid=false
    fi

    # Check if PostgreSQL is running
    if [[ "$SKIP_DB" == "false" ]]; then
        if command_exists pg_isready; then
            if pg_isready -h $DB_HOST -p $DB_PORT >/dev/null 2>&1; then
                log_info "PostgreSQL is running"
            else
                log_error "PostgreSQL is not running"
                services_valid=false
            fi
        fi
    fi

    # Check if Redis is running (if configured)
    if [[ "$REDIS" == "true" ]]; then
        if command_exists redis-cli; then
            if redis-cli ping | grep -q "PONG"; then
                log_info "Redis is running"
            else
                log_error "Redis is not running"
                services_valid=false
            fi
        fi
    fi

    # Check port availability
    local ports_to_check=(3000 5000)
    if [[ "$SKIP_DB" == "false" ]]; then
        ports_to_check+=(5432)
    fi
    if [[ "$REDIS" == "true" ]]; then
        ports_to_check+=(6379)
    fi

    for port in "${ports_to_check[@]}"; do
        if command_exists netstat; then
            if netstat -tuln 2>/dev/null | grep -q ":$port "; then
                log_warning "Port $port is already in use"
            fi
        fi
    done

    return $services_valid
}

# Start development servers
start_development_servers() {
    log_info "Starting development servers..."

    # Check if we're in the project directory
    if [[ ! -f "package.json" ]]; then
        log_error "Not in project directory"
        return 1
    fi

    # Start servers in background
    if [[ -d "server" ]]; then
        log_info "Starting backend server..."
        cd server
        npm run dev &
        SERVER_PID=$!
        cd ..
    fi

    if [[ -d "client" ]]; then
        log_info "Starting frontend server..."
        cd client
        npm start &
        CLIENT_PID=$!
        cd ..
    fi

    # Wait a moment for servers to start
    sleep 3

    # Check if servers are running
    if [[ -n "$SERVER_PID" ]] && kill -0 $SERVER_PID 2>/dev/null; then
        log_success "Backend server started (PID: $SERVER_PID)"
    fi

    if [[ -n "$CLIENT_PID" ]] && kill -0 $CLIENT_PID 2>/dev/null; then
        log_success "Frontend server started (PID: $CLIENT_PID)"
    fi

    log_info "Development servers started!"
    log_info "Backend: http://localhost:5000"
    log_info "Frontend: http://localhost:3000"
}

# Open project in VS Code
open_in_vscode() {
    if command_exists code; then
        log_info "Opening project in VS Code..."
        code "$PROJECT_PATH"
        log_success "Project opened in VS Code"
    else
        log_error "VS Code not found. Please open the project manually: $PROJECT_PATH"
    fi
}

# Show project documentation
show_documentation() {
    log_info "=== Project Documentation ==="
    echo "Project: $PROJECT_NAME"
    echo "Location: $PROJECT_PATH"
    echo "Database: $DB_NAME"
    echo "Database User: $DB_USER"
    echo

    if [[ -f "README.md" ]]; then
        log_info "README.md found. Contents:"
        echo "---"
        cat README.md
        echo "---"
    else
        log_info "No README.md found. Creating basic documentation..."
        create_readme
    fi
}

# Create README file
create_readme() {
    local readme_file="$PROJECT_PATH/README.md"
    cat > "$readme_file" << EOF
# $PROJECT_NAME

A PERN (PostgreSQL, Express.js, React, Node.js) stack application.

## Getting Started

### Prerequisites

- Node.js (v16 or higher)
- PostgreSQL
- npm or yarn

### Installation

1. Clone the repository
2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Set up environment variables:
   \`\`\`bash
   cp .env.example .env
   # Edit .env with your configuration
   \`\`\`

4. Set up the database:
   \`\`\`bash
   # Run database migrations if available
   npm run migrate
   \`\`\`

### Development

Start the development servers:

\`\`\`bash
npm run dev
\`\`\`

This will start both the backend (port 5000) and frontend (port 3000) servers.

### Building

Build the application:

\`\`\`bash
npm run build
\`\`\`

### Testing

Run tests:

\`\`\`bash
npm test
\`\`\`

## Project Structure

\`\`\`
├── client/          # React frontend
├── server/          # Express.js backend
├── docs/            # Documentation
├── tests/           # Test files
└── config/          # Configuration files
\`\`\`

## Environment Variables

Copy \`.env.example\` to \`.env\` and configure the following variables:

- \`NODE_ENV\`: Environment (development/production)
- \`PORT\`: Server port
- \`DB_HOST\`: Database host
- \`DB_PORT\`: Database port
- \`DB_NAME\`: Database name
- \`DB_USER\`: Database user
- \`DB_PASSWORD\`: Database password
- \`JWT_SECRET\`: JWT secret key

## Scripts

- \`npm run dev\`: Start development servers
- \`npm run build\`: Build the application
- \`npm test\`: Run tests
- \`npm run lint\`: Run linter
- \`npm run format\`: Format code

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request

## License

This project is licensed under the MIT License.
EOF

    log_success "README.md created"
}

# Show installation summary
show_installation_summary() {
    log_info "=== Installation Summary ==="

    echo "✅ Project: $PROJECT_NAME"
    echo "📍 Location: $PROJECT_PATH"

    if [[ "$SKIP_DB" == "false" ]]; then
        echo "🔌 Database: $DB_NAME"
        echo "👤 Database User: $DB_USER"
        echo "🔑 Database Host: $DB_HOST:$DB_PORT"
    else
        echo "⏭️  Database setup was skipped"
    fi

    if [[ -f ".env" ]]; then
        echo "🔐 Environment file created"
    fi

    if [[ -d "server" ]]; then
        echo "🚀 Backend: Express.js server"
    fi

    if [[ -d "client" ]]; then
        echo "⚛️  Frontend: React application"
    fi

    if [[ -f "Dockerfile" ]]; then
        echo "🐳 Docker support enabled"
    fi

    if [[ -f ".github/workflows/ci.yml" ]]; then
        echo "🔄 CI/CD pipeline configured"
    fi

    echo
    log_info "=== Next Steps ==="
    echo "1. Review and customize the configuration files"
    echo "2. Start the development servers: npm run dev"
    echo "3. Open your browser and visit http://localhost:3000"
    echo "4. Check the README.md for detailed documentation"
    echo
    log_info "=== Useful Commands ==="
    echo "Development: npm run dev"
    echo "Build: npm run build"
    echo "Test: npm test"
    echo "Lint: npm run lint"
    echo "Format: npm run format"
}