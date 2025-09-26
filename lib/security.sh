#!/bin/bash

# Security and environment configuration functions

# Generate secure configuration
generate_secure_config() {
    log_info "Generating secure configuration..."

    # Generate JWT secrets
    local jwt_secret=$(generate_random_string 64)
    local jwt_refresh_secret=$(generate_random_string 64)

    # Generate API keys
    local api_key=$(generate_random_string 32)
    local api_secret=$(generate_random_string 64)

    # Generate session secret
    local session_secret=$(generate_random_string 64)

    # Create .env file
    local env_file="$PROJECT_PATH/.env"
    if [[ -f "$env_file" ]]; then
        backup_file "$env_file"
    fi

    cat > "$env_file" << EOF
# JWT Configuration
JWT_SECRET=$jwt_secret
JWT_REFRESH_SECRET=$jwt_refresh_secret
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# API Keys
API_KEY=$api_key
API_SECRET=$api_secret

# Session Configuration
SESSION_SECRET=$session_secret
SESSION_COOKIE_MAX_AGE=86400000

# Database Configuration (will be updated by database setup)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=pern_app
DB_USER=pern_user
DB_PASSWORD=secure_password_here

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# Application Configuration
NODE_ENV=development
PORT=5000
CLIENT_PORT=3000

# CORS Configuration
CORS_ORIGIN=http://localhost:3000
CORS_CREDENTIALS=true

# Logging
LOG_LEVEL=info

# SSL/TLS Configuration
SSL_CERT_PATH=./ssl/cert.pem
SSL_KEY_PATH=./ssl/key.pem
EOF

    # Create .env.example file
    local env_example="$PROJECT_PATH/.env.example"
    cat > "$env_example" << 'EOF'
# JWT Configuration
JWT_SECRET=your_jwt_secret_here
JWT_REFRESH_SECRET=your_jwt_refresh_secret_here
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# API Keys
API_KEY=your_api_key_here
API_SECRET=your_api_secret_here

# Session Configuration
SESSION_SECRET=your_session_secret_here
SESSION_COOKIE_MAX_AGE=86400000

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_database_name
DB_USER=your_database_user
DB_PASSWORD=your_database_password

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# Application Configuration
NODE_ENV=development
PORT=5000
CLIENT_PORT=3000

# CORS Configuration
CORS_ORIGIN=http://localhost:3000
CORS_CREDENTIALS=true

# Logging
LOG_LEVEL=info

# SSL/TLS Configuration
SSL_CERT_PATH=./ssl/cert.pem
SSL_KEY_PATH=./ssl/key.pem
EOF

    log_success "Secure configuration generated"
    log_info "Generated JWT secret: ${jwt_secret:0:20}..."
    log_info "Generated API key: ${api_key:0:20}..."
}

# Configure CORS settings
configure_cors() {
    log_info "Configuring CORS settings..."

    local cors_origin=$(get_input "CORS origin (default: http://localhost:3000)" "" "http://localhost:3000")
    local cors_credentials=$(confirm "Allow credentials in CORS?" "y")

    # Update .env file
    local env_file="$PROJECT_PATH/.env"
    if [[ -f "$env_file" ]]; then
        sed -i "s|CORS_ORIGIN=.*|CORS_ORIGIN=$cors_origin|" "$env_file"
        if [[ "$cors_credentials" == "true" ]]; then
            sed -i "s/CORS_CREDENTIALS=.*/CORS_CREDENTIALS=true/" "$env_file"
        else
            sed -i "s/CORS_CREDENTIALS=.*/CORS_CREDENTIALS=false/" "$env_file"
        fi
    fi

    # Create CORS configuration file
    local cors_config="$PROJECT_PATH/server/config/cors.js"
    create_directory "$(dirname "$cors_config")"

    cat > "$cors_config" << EOF
const cors = require('cors');

// CORS configuration
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);

    const allowedOrigins = [
      '$cors_origin',
      'http://localhost:3000',
      'http://localhost:3001',
      'http://127.0.0.1:3000',
      'http://127.0.0.1:3001'
    ];

    if (allowedOrigins.indexOf(origin) !== -1 || process.env.NODE_ENV === 'development') {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: $cors_credentials,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
};

module.exports = cors(corsOptions);
EOF

    log_success "CORS configuration completed"
}

# Set up SSL/TLS certificates
setup_ssl() {
    log_info "Setting up SSL/TLS certificates..."

    # Create SSL directory
    local ssl_dir="$PROJECT_PATH/ssl"
    create_directory "$ssl_dir"

    # Check if OpenSSL is available
    if ! command_exists openssl; then
        log_error "OpenSSL is required for SSL certificate generation"
        if confirm "Install OpenSSL?"; then
            local os=$(detect_os)
            case $os in
                "linux")
                    if command_exists apt; then
                        sudo apt-get update && sudo apt-get install -y openssl
                    elif command_exists yum; then
                        sudo yum install -y openssl
                    fi
                    ;;
                "macos")
                    if command_exists brew; then
                        brew install openssl
                    fi
                    ;;
            esac
        else
            log_warning "Skipping SSL setup"
            return 0
        fi
    fi

    # Generate self-signed certificate
    local cert_file="$ssl_dir/cert.pem"
    local key_file="$ssl_dir/key.pem"

    openssl req -x509 -newkey rsa:4096 -keyout "$key_file" -out "$cert_file" \
        -days 365 -nodes -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

    # Set proper permissions
    chmod 600 "$key_file"
    chmod 644 "$cert_file"

    # Update .env file
    local env_file="$PROJECT_PATH/.env"
    if [[ -f "$env_file" ]]; then
        sed -i "s|SSL_CERT_PATH=.*|SSL_CERT_PATH=$ssl_dir/cert.pem|" "$env_file"
        sed -i "s|SSL_KEY_PATH=.*|SSL_KEY_PATH=$ssl_dir/key.pem|" "$env_file"
    fi

    log_success "SSL certificates generated"
    log_info "Certificate: $cert_file"
    log_info "Private key: $key_file"
}

# Configure logging levels
configure_logging() {
    log_info "Configuring logging levels..."

    local log_level=$(get_input "Log level (debug, info, warn, error)" "" "info")

    # Update .env file
    local env_file="$PROJECT_PATH/.env"
    if [[ -f "$env_file" ]]; then
        sed -i "s/LOG_LEVEL=.*/LOG_LEVEL=$log_level/" "$env_file"
    fi

    # Create logging configuration
    local log_config="$PROJECT_PATH/server/config/logger.js"
    create_directory "$(dirname "$log_config")"

    cat > "$log_config" << EOF
const winston = require('winston');

// Define log levels
const levels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

// Define colors for each level
const colors = {
  error: 'red',
  warn: 'yellow',
  info: 'green',
  http: 'magenta',
  debug: 'white',
};

winston.addColors(colors);

// Create logger format
const format = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
  winston.format.colorize({ all: true }),
  winston.format.printf(
    (info) => \`\${info.timestamp} \${info.level}: \${info.message}\`,
  ),
);

// Create transports
const transports = [
  new winston.transports.Console({
    format: format,
    level: '$log_level',
  }),
  new winston.transports.File({
    filename: 'logs/error.log',
    level: 'error',
  }),
  new winston.transports.File({
    filename: 'logs/all.log',
  }),
];

// Create logger
const logger = winston.createLogger({
  level: '$log_level',
  levels,
  format,
  transports,
});

module.exports = logger;
EOF

    log_success "Logging configuration completed"
}

# Custom security setup
custom_security_setup() {
    log_info "Running custom security setup..."

    # Rate limiting
    if confirm "Set up rate limiting?"; then
        setup_rate_limiting
    fi

    # Helmet security headers
    if confirm "Set up security headers (Helmet)?"; then
        setup_helmet
    fi

    # Input validation and sanitization
    if confirm "Set up input validation?"; then
        setup_validation
    fi

    # Security audit
    if confirm "Run security audit?"; then
        run_security_audit
    fi

    log_success "Custom security setup completed"
}

# Set up rate limiting
setup_rate_limiting() {
    log_info "Setting up rate limiting..."

    local window_ms=$(get_input "Rate limit window (minutes)" "" "15")
    local max_requests=$(get_input "Max requests per window" "" "100")

    # Create rate limiting middleware
    local rate_limit_config="$PROJECT_PATH/server/middleware/rateLimiter.js"
    create_directory "$(dirname "$rate_limit_config")"

    cat > "$rate_limit_config" << EOF
const rateLimit = require('express-rate-limit');

// Rate limiting configuration
const createRateLimit = (windowMs = $window_ms * 60 * 1000, max = $max_requests) => {
  return rateLimit({
    windowMs: windowMs, // $window_ms minutes
    max: max, // Limit each IP to $max_requests requests per windowMs
    message: {
      error: 'Too many requests from this IP, please try again later.',
    },
    standardHeaders: true, // Return rate limit info in the \`RateLimit-*\` headers
    legacyHeaders: false, // Disable the \`X-RateLimit-*\` headers
    skip: (req) => {
      // Skip rate limiting for health checks
      return req.path === '/health' || req.path === '/api/health';
    },
  });
};

// General API rate limiter
const apiLimiter = createRateLimit();

// Strict rate limiter for authentication endpoints
const authLimiter = createRateLimit(15 * 60 * 1000, 5); // 5 requests per 15 minutes

// File upload rate limiter
const uploadLimiter = createRateLimit(60 * 60 * 1000, 10); // 10 uploads per hour

module.exports = {
  apiLimiter,
  authLimiter,
  uploadLimiter,
  createRateLimit,
};
EOF

    log_success "Rate limiting setup completed"
}

# Set up Helmet security headers
setup_helmet() {
    log_info "Setting up Helmet security headers..."

    # Create security middleware
    local security_config="$PROJECT_PATH/server/middleware/security.js"
    create_directory "$(dirname "$security_config")"

    cat > "$security_config" << 'EOF'
const helmet = require('helmet');

// Security middleware configuration
const securityMiddleware = helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://api.example.com"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  },
  noSniff: true,
  xssFilter: true,
  referrerPolicy: { policy: "strict-origin-when-cross-origin" },
});

module.exports = securityMiddleware;
EOF

    log_success "Helmet security headers setup completed"
}

# Set up input validation
setup_validation() {
    log_info "Setting up input validation..."

    # Create validation utilities
    local validation_utils="$PROJECT_PATH/server/utils/validation.js"
    create_directory "$(dirname "$validation_utils")"

    cat > "$validation_utils" << 'EOF'
const validator = require('validator');

// Input validation utilities
const ValidationUtils = {
  // Sanitize user input
  sanitizeInput: (input) => {
    if (typeof input === 'string') {
      return validator.escape(input.trim());
    }
    return input;
  },

  // Validate email
  isValidEmail: (email) => {
    return validator.isEmail(email);
  },

  // Validate password strength
  isValidPassword: (password) => {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$/;
    return passwordRegex.test(password);
  },

  // Validate username
  isValidUsername: (username) => {
    // 3-30 characters, alphanumeric, underscore, hyphen
    const usernameRegex = /^[a-zA-Z0-9_-]{3,30}$/;
    return usernameRegex.test(username);
  },

  // Validate URL
  isValidURL: (url) => {
    return validator.isURL(url, {
      protocols: ['http', 'https'],
      require_protocol: true,
    });
  },

  // Sanitize and validate object
  sanitizeObject: (obj, fields) => {
    const sanitized = {};
    for (const field of fields) {
      if (obj[field] !== undefined) {
        sanitized[field] = ValidationUtils.sanitizeInput(obj[field]);
      }
    }
    return sanitized;
  },

  // Validation error response
  validationError: (message, field) => {
    return {
      error: 'Validation Error',
      message,
      field,
    };
  },
};

module.exports = ValidationUtils;
EOF

    log_success "Input validation setup completed"
}

# Run security audit
run_security_audit() {
    log_info "Running security audit..."

    local audit_results=()

    # Check for common security issues
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        # Check for outdated packages
        if command_exists npm; then
            log_info "Checking for outdated packages..."
            local outdated=$(cd "$PROJECT_PATH" && npm outdated 2>/dev/null || true)
            if [[ -n "$outdated" ]]; then
                audit_results+=("Outdated packages found - consider updating")
            else
                audit_results+=("All packages are up to date")
            fi
        fi

        # Check for security vulnerabilities
        if command_exists npm; then
            log_info "Running npm audit..."
            local audit=$(cd "$PROJECT_PATH" && npm audit --audit-level moderate 2>/dev/null || true)
            if [[ -n "$audit" ]]; then
                audit_results+=("Security vulnerabilities found - run 'npm audit fix'")
            else
                audit_results+=("No security vulnerabilities found")
            fi
        fi
    fi

    # Check environment variables
    if [[ -f "$PROJECT_PATH/.env" ]]; then
        if grep -q "password\|secret\|key" "$PROJECT_PATH/.env" | grep -v "=" | head -5; then
            audit_results+=("Sensitive data found in .env file - ensure it's not committed to version control")
        fi
    fi

    # Check for .env in .gitignore
    if [[ -f "$PROJECT_PATH/.gitignore" ]]; then
        if ! grep -q "\.env" "$PROJECT_PATH/.gitignore"; then
            audit_results+=(".env file not found in .gitignore - add it to prevent credential leaks")
        fi
    fi

    # Display audit results
    log_info "=== Security Audit Results ==="
    for result in "${audit_results[@]}"; do
        echo "- $result"
    done

    log_success "Security audit completed"
}

# Create environment files for different environments
create_multi_env() {
    if [[ "$MULTI_ENV" == "true" ]]; then
        log_info "Creating multi-environment configuration..."

        # Development environment
        local env_dev="$PROJECT_PATH/.env.development"
        cat > "$env_dev" << EOF
NODE_ENV=development
PORT=5000
CLIENT_PORT=3000
DB_HOST=localhost
DB_PORT=5432
LOG_LEVEL=debug
EOF

        # Production environment
        local env_prod="$PROJECT_PATH/.env.production"
        cat > "$env_prod" << EOF
NODE_ENV=production
PORT=5000
CLIENT_PORT=3000
DB_HOST=prod-db-host
DB_PORT=5432
LOG_LEVEL=warn
EOF

        # Test environment
        local env_test="$PROJECT_PATH/.env.test"
        cat > "$env_test" << EOF
NODE_ENV=test
PORT=5001
CLIENT_PORT=3001
DB_HOST=localhost
DB_PORT=5433
LOG_LEVEL=error
EOF

        log_success "Multi-environment configuration created"
    fi
}