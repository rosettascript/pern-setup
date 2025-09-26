#!/bin/bash

# Database operations and setup functions

# Auto database setup with random credentials
setup_auto_database() {
    log_info "Setting up PostgreSQL database with auto-generated credentials..."

    # Generate random credentials
    DB_NAME="pern_app_$(generate_random_string 8)"
    DB_USER="pern_user_$(generate_random_string 8)"
    DB_PASSWORD=$(generate_random_string 16)

    log_info "Generated database name: $DB_NAME"
    log_info "Generated database user: $DB_USER"

    # Check if PostgreSQL is running
    if ! pg_isready -q; then
        log_error "PostgreSQL is not running. Please start PostgreSQL service."
        if confirm "Start PostgreSQL service?"; then
            sudo systemctl start postgresql 2>/dev/null || service postgresql start 2>/dev/null || log_error "Could not start PostgreSQL"
        fi
    fi

    # Create database and user
    if create_database_user; then
        log_success "Database setup completed successfully"
        SKIP_DB=false
    else
        log_error "Database setup failed"
        if confirm "Continue without database setup?"; then
            SKIP_DB=true
        else
            return 1
        fi
    fi
}

# Custom database setup with user input
setup_custom_database() {
    log_info "Setting up PostgreSQL database with custom configuration..."

    # Get database configuration from user
    DB_NAME=$(get_input "Database name" validate_project_name "pern_app")
    DB_USER=$(get_input "Database user" "" "pern_user")
    DB_PASSWORD=$(get_input "Database password" "" "")
    DB_HOST=$(get_input "Database host" "" "localhost")
    DB_PORT=$(get_input "Database port" "" "5432")

    # Validate password strength
    if ! validate_password "$DB_PASSWORD" 8; then
        log_error "Password does not meet security requirements"
        return 1
    fi

    # Test database connection
    if test_database_connection; then
        log_success "Database connection successful"
        SKIP_DB=false
    else
        log_error "Database connection failed"
        if confirm "Continue with database setup anyway?"; then
            SKIP_DB=false
        else
            SKIP_DB=true
        fi
    fi
}

# Docker database setup
setup_docker_database() {
    log_info "Setting up PostgreSQL with Docker..."

    # Check if Docker is available
    if ! command_exists docker; then
        log_error "Docker is not installed"
        if confirm "Install Docker?"; then
            install_docker
        else
            log_error "Docker is required for containerized database setup"
            return 1
        fi
    fi

    # Generate random credentials
    DB_NAME="pern_app_$(generate_random_string 8)"
    DB_USER="pern_user_$(generate_random_string 8)"
    DB_PASSWORD=$(generate_random_string 16)
    DB_HOST="localhost"
    DB_PORT="5432"

    log_info "Generated database name: $DB_NAME"
    log_info "Generated database user: $DB_USER"

    # Create Docker network if it doesn't exist
    docker network create pern-network 2>/dev/null || true

    # Run PostgreSQL container
    docker run --name postgres-pern \
        -e POSTGRES_DB=$DB_NAME \
        -e POSTGRES_USER=$DB_USER \
        -e POSTGRES_PASSWORD=$DB_PASSWORD \
        -p $DB_PORT:5432 \
        --network pern-network \
        -d postgres:15-alpine

    # Wait for database to be ready
    log_info "Waiting for database to be ready..."
    sleep 10

    # Test connection
    if test_database_connection; then
        log_success "Docker database setup completed successfully"
        SKIP_DB=false
    else
        log_error "Docker database setup failed"
        docker stop postgres-pern 2>/dev/null || true
        docker rm postgres-pern 2>/dev/null || true
        return 1
    fi
}

# Remote database setup
setup_remote_database() {
    log_info "Setting up remote database connection..."

    DB_HOST=$(get_input "Database host" "" "")
    DB_PORT=$(get_input "Database port" "" "5432")
    DB_NAME=$(get_input "Database name" "" "")
    DB_USER=$(get_input "Database user" "" "")
    DB_PASSWORD=$(get_input "Database password" "" "")

    # Test database connection
    if test_database_connection; then
        log_success "Remote database connection successful"
        SKIP_DB=false
    else
        log_error "Remote database connection failed"
        if confirm "Continue with remote database setup anyway?"; then
            SKIP_DB=false
        else
            SKIP_DB=true
        fi
    fi
}

# Create database user and database
create_database_user() {
    log_info "Creating database user and database..."

    # Check if we're using local PostgreSQL
    if [[ "$DB_HOST" == "localhost" || "$DB_HOST" == "127.0.0.1" ]]; then
        # Create user and database using psql
        sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';" 2>/dev/null || \
        psql -h $DB_HOST -p $DB_PORT -U postgres -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';" 2>/dev/null || true

        sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" 2>/dev/null || \
        psql -h $DB_HOST -p $DB_PORT -U postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" 2>/dev/null || true

        sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" 2>/dev/null || \
        psql -h $DB_HOST -p $DB_PORT -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" 2>/dev/null || true
    else
        # For remote databases, just test the connection
        if test_database_connection; then
            log_success "Remote database connection verified"
            return 0
        else
            log_error "Cannot connect to remote database"
            return 1
        fi
    fi

    # Test the connection with the new credentials
    if test_database_connection; then
        log_success "Database user and database created successfully"
        return 0
    else
        log_error "Failed to create database user and database"
        return 1
    fi
}

# Test database connection
test_database_connection() {
    log_info "Testing database connection..."

    # Try different connection methods
    if command_exists psql; then
        # Use psql to test connection
        if PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;" >/dev/null 2>&1; then
            log_success "Database connection successful"
            return 0
        fi
    fi

    # Try using pg_isready if available
    if command_exists pg_isready; then
        if pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME >/dev/null 2>&1; then
            log_success "Database connection successful"
            return 0
        fi
    fi

    # Try using node-postgres if available
    if command_exists node; then
        local test_script=$(mktemp)
        cat > "$test_script" << EOF
const { Client } = require('pg');
const client = new Client({
  host: '$DB_HOST',
  port: $DB_PORT,
  user: '$DB_USER',
  password: '$DB_PASSWORD',
  database: '$DB_NAME'
});

client.connect()
  .then(() => {
    console.log('Database connection successful');
    process.exit(0);
  })
  .catch((err) => {
    console.error('Database connection failed:', err.message);
    process.exit(1);
  });
EOF

        if node "$test_script" 2>/dev/null; then
            log_success "Database connection successful"
            rm -f "$test_script"
            return 0
        fi
        rm -f "$test_script"
    fi

    log_error "Database connection failed"
    return 1
}

# Initialize database with sample tables
initialize_sample_data() {
    if [[ "$SAMPLE_DATA" == "true" ]]; then
        log_info "Initializing database with sample data..."

        local init_script=$(mktemp)
        cat > "$init_script" << 'EOF'
-- Sample tables for PERN stack application

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Posts table
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    author_id INTEGER REFERENCES users(id),
    published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Comments table
CREATE TABLE IF NOT EXISTS comments (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    author_id INTEGER REFERENCES users(id),
    post_id INTEGER REFERENCES posts(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (username, email, password_hash, first_name, last_name) VALUES
('johndoe', 'john@example.com', '$2b$10$samplehash1', 'John', 'Doe'),
('janedoe', 'jane@example.com', '$2b$10$samplehash2', 'Jane', 'Doe')
ON CONFLICT (username) DO NOTHING;

INSERT INTO posts (title, content, author_id, published) VALUES
('Welcome to PERN Stack', 'This is a sample post to demonstrate the PERN stack setup.', 1, true),
('Getting Started', 'Learn how to build applications with PostgreSQL, Express.js, React, and Node.js.', 2, true)
ON CONFLICT DO NOTHING;

INSERT INTO comments (content, author_id, post_id) VALUES
('Great post!', 2, 1),
('Very helpful, thanks!', 1, 2)
ON CONFLICT DO NOTHING;
EOF

        # Execute the script
        if PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$init_script" >/dev/null 2>&1; then
            log_success "Sample data initialized successfully"
        else
            log_warning "Failed to initialize sample data"
        fi

        rm -f "$init_script"
    fi
}

# Set up database migrations
setup_migrations() {
    if [[ "$MIGRATIONS" == "true" ]]; then
        log_info "Setting up database migrations..."

        # Create migrations directory
        local migrations_dir="$PROJECT_PATH/server/migrations"
        create_directory "$migrations_dir"

        # Create initial migration
        local migration_file="$migrations_dir/001_initial_schema.sql"
        cat > "$migration_file" << 'EOF'
-- Initial database schema migration

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    author_id INTEGER REFERENCES users(id),
    published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS comments (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    author_id INTEGER REFERENCES users(id),
    post_id INTEGER REFERENCES posts(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_posts_author_id ON posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_published ON posts(published);
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_author_id ON comments(author_id);
EOF

        log_success "Database migrations setup completed"
    fi
}

# Configure Redis for sessions/caching
setup_redis() {
    if [[ "$REDIS" == "true" ]]; then
        log_info "Setting up Redis configuration..."

        # Test Redis connection
        if command_exists redis-cli; then
            if redis-cli ping | grep -q "PONG"; then
                log_success "Redis connection successful"
            else
                log_error "Redis connection failed"
                return 1
            fi
        else
            log_error "Redis CLI not found"
            return 1
        fi

        # Create Redis configuration
        local redis_config="$PROJECT_PATH/server/config/redis.js"
        create_directory "$(dirname "$redis_config")"

        cat > "$redis_config" << 'EOF'
const redis = require('redis');

// Redis configuration
const redisConfig = {
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD || undefined,
  db: process.env.REDIS_DB || 0,
  retry_strategy: (options) => {
    if (options.error && options.error.code === 'ECONNREFUSED') {
      return new Error('Redis server connection refused');
    }
    if (options.total_retry_time > 1000 * 60 * 60) {
      return new Error('Redis retry time exhausted');
    }
    if (options.attempt > 10) {
      return undefined;
    }
    return Math.min(options.attempt * 100, 3000);
  }
};

// Create Redis client
const client = redis.createClient(redisConfig);

// Handle connection events
client.on('connect', () => {
  console.log('Connected to Redis');
});

client.on('error', (err) => {
  console.error('Redis connection error:', err);
});

module.exports = client;
EOF

        log_success "Redis configuration created"
    fi
}

# Create database connection configuration
create_database_config() {
    log_info "Creating database configuration..."

    # Create server config directory
    local config_dir="$PROJECT_PATH/server/config"
    create_directory "$config_dir"

    # Create database configuration file
    local db_config="$config_dir/database.js"
    cat > "$db_config" << EOF
const { Pool } = require('pg');

// Database configuration
const dbConfig = {
  host: '$DB_HOST',
  port: $DB_PORT,
  database: '$DB_NAME',
  user: '$DB_USER',
  password: '$DB_PASSWORD',
  max: 20, // maximum number of connections
  idleTimeoutMillis: 30000, // close idle connections after 30 seconds
  connectionTimeoutMillis: 2000, // return an error after 2 seconds if connection could not be established
  maxUses: 7500, // close (and replace) a connection after it has been used 7500 times
};

// Create connection pool
const pool = new Pool(dbConfig);

// Handle pool events
pool.on('connect', (client) => {
  if (process.env.NODE_ENV !== 'test') {
    console.log('New client connected to PostgreSQL');
  }
});

pool.on('error', (err, client) => {
  console.error('Unexpected error on idle client:', err);
  process.exit(-1);
});

// Query helper function
const query = async (text, params) => {
  const start = Date.now();
  try {
    const res = await pool.query(text, params);
    const duration = Date.now() - start;
    if (process.env.NODE_ENV !== 'test') {
      console.log('Executed query:', { text, duration, rows: res.rowCount });
    }
    return res;
  } catch (err) {
    const duration = Date.now() - start;
    console.error('Database query error:', { text, duration, error: err.message });
    throw err;
  }
};

module.exports = {
  pool,
  query
};
EOF

    log_success "Database configuration created"
}

# Create environment file with database settings
create_database_env() {
    log_info "Creating database environment configuration..."

    # Create .env file
    local env_file="$PROJECT_PATH/.env"
    if [[ -f "$env_file" ]]; then
        backup_file "$env_file"
    fi

    cat > "$env_file" << EOF
# Database Configuration
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD

# Redis Configuration (if enabled)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# Application Configuration
NODE_ENV=development
PORT=5000
CLIENT_PORT=3000
EOF

    log_success "Database environment configuration created"
}

# Validate database setup
validate_database_setup() {
    log_info "Validating database setup..."

    # Test connection
    if test_database_connection; then
        log_success "Database connection validation passed"
    else
        log_error "Database connection validation failed"
        return 1
    fi

    # Check if we can create tables
    if PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "CREATE TABLE IF NOT EXISTS validation_test (id SERIAL);" >/dev/null 2>&1; then
        log_success "Database write permissions validated"
        # Clean up test table
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "DROP TABLE IF EXISTS validation_test;" >/dev/null 2>&1
    else
        log_error "Database write permissions validation failed"
        return 1
    fi

    return 0
}