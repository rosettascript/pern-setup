#!/bin/bash

# Development tools setup functions

# Set up code quality tools
setup_code_quality_tools() {
    log_info "Setting up code quality tools..."

    # Create package.json if it doesn't exist
    if [[ ! -f "$PROJECT_PATH/package.json" ]]; then
        create_package_json "$PROJECT_PATH" "$PROJECT_NAME" "fullstack"
    fi

    # Install ESLint and Prettier
    cd "$PROJECT_PATH"
    npm install --save-dev eslint @eslint/js prettier eslint-config-prettier eslint-plugin-prettier

    # Install React-specific packages if it's a React project
    if [[ -d "$PROJECT_PATH/client" ]]; then
        cd "$PROJECT_PATH/client"
        npm install --save-dev eslint @eslint/js prettier eslint-config-prettier eslint-plugin-prettier eslint-plugin-react eslint-plugin-react-hooks eslint-plugin-jsx-a11y
    fi

    # Create ESLint configuration
    local eslint_config="$PROJECT_PATH/.eslintrc.json"
    cat > "$eslint_config" << 'EOF'
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true,
    "jest": true
  },
  "extends": [
    "eslint:recommended",
    "@eslint/js/recommended",
    "prettier"
  ],
  "parserOptions": {
    "ecmaFeatures": {
      "jsx": true
    },
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "plugins": [
    "prettier"
  ],
  "rules": {
    "prettier/prettier": "error",
    "no-unused-vars": "warn",
    "no-console": "off",
    "prefer-const": "error",
    "no-var": "error"
  }
}
EOF

    # Create Prettier configuration
    local prettier_config="$PROJECT_PATH/.prettierrc"
    cat > "$prettier_config" << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
EOF

    # Create .prettierignore
    local prettier_ignore="$PROJECT_PATH/.prettierignore"
    cat > "$prettier_ignore" << 'EOF'
node_modules
build
dist
coverage
*.min.js
*.min.css
public
EOF

    # Create EditorConfig
    local editorconfig="$PROJECT_PATH/.editorconfig"
    cat > "$editorconfig" << 'EOF'
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 2
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false

[*.{yml,yaml}]
indent_size = 2
EOF

    log_success "Code quality tools setup completed"
}

# Set up testing framework
setup_testing_framework() {
    log_info "Setting up testing framework..."

    # Create package.json if it doesn't exist
    if [[ ! -f "$PROJECT_PATH/package.json" ]]; then
        create_package_json "$PROJECT_PATH" "$PROJECT_NAME" "fullstack"
    fi

    cd "$PROJECT_PATH"

    # Install Jest and Supertest
    npm install --save-dev jest supertest cross-env

    # Install React Testing Library if it's a React project
    if [[ -d "$PROJECT_PATH/client" ]]; then
        cd "$PROJECT_PATH/client"
        npm install --save-dev @testing-library/react @testing-library/jest-dom @testing-library/user-event jest-environment-jsdom
    fi

    # Create Jest configuration
    local jest_config="$PROJECT_PATH/jest.config.js"
    cat > "$jest_config" << 'EOF'
module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/__tests__/**/*.js', '**/?(*.)+(spec|test).js'],
  collectCoverageFrom: [
    'server/**/*.js',
    '!server/**/*.test.js',
    '!server/**/*.spec.js'
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  setupFilesAfterEnv: ['<rootDir>/server/tests/setup.js'],
  verbose: true
};
EOF

    # Create test setup file
    create_directory "$PROJECT_PATH/server/tests"
    local test_setup="$PROJECT_PATH/server/tests/setup.js"
    cat > "$test_setup" << 'EOF'
// Test setup file
const { jest } = require('@jest/globals');

// Set test timeout
jest.setTimeout(10000);

// Global test utilities
global.testUtils = {
  // Add any global test utilities here
};

// Clean up after each test
afterEach(() => {
  // Add cleanup logic here
});
EOF

    # Create sample test files
    local server_test="$PROJECT_PATH/server/tests/app.test.js"
    cat > "$server_test" << 'EOF'
const request = require('supertest');
const app = require('../app');

describe('API Tests', () => {
  test('GET /health should return 200', async () => {
    const response = await request(app)
      .get('/health')
      .expect(200);

    expect(response.body).toHaveProperty('status', 'ok');
  });

  test('GET /api should return 200', async () => {
    const response = await request(app)
      .get('/api')
      .expect(200);

    expect(response.body).toHaveProperty('message');
  });
});
EOF

    # Update package.json scripts
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        # Add test scripts to package.json
        sed -i 's/"scripts": {/"scripts": {\n    "test": "cross-env NODE_ENV=test jest",\n    "test:watch": "cross-env NODE_ENV=test jest --watch",\n    "test:coverage": "cross-env NODE_ENV=test jest --coverage",/' "$PROJECT_PATH/package.json"
    fi

    log_success "Testing framework setup completed"
}

# Set up Git hooks
setup_git_hooks() {
    log_info "Setting up Git hooks..."

    # Create package.json if it doesn't exist
    if [[ ! -f "$PROJECT_PATH/package.json" ]]; then
        create_package_json "$PROJECT_PATH" "$PROJECT_NAME" "fullstack"
    fi

    cd "$PROJECT_PATH"

    # Install Husky and lint-staged
    npm install --save-dev husky lint-staged

    # Initialize Husky
    npx husky install

    # Add pre-commit hook
    npx husky add .husky/pre-commit "npx lint-staged"

    # Create .lintstagedrc.json
    local lintstaged_config="$PROJECT_PATH/.lintstagedrc.json"
    cat > "$lintstaged_config" << 'EOF'
{
  "*.{js,jsx,ts,tsx}": [
    "eslint --fix",
    "prettier --write"
  ],
  "*.{json,css,md}": [
    "prettier --write"
  ]
}
EOF

    log_success "Git hooks setup completed"
}

# Set up Docker support
setup_docker_support() {
    log_info "Setting up Docker support..."

    # Create Dockerfile
    local dockerfile="$PROJECT_PATH/Dockerfile"
    cat > "$dockerfile" << 'EOF'
# Multi-stage Docker build for PERN stack application

# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY server/package*.json ./server/
COPY client/package*.json ./client/

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Build client
RUN cd client && npm ci && npm run build

# Production stage
FROM node:18-alpine AS production

WORKDIR /app

# Create app user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S pernapp -u 1001

# Copy built application
COPY --from=builder --chown=pernapp:nodejs /app .

# Switch to non-root user
USER pernapp

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node server/healthcheck.js

# Start application
CMD ["npm", "start"]
EOF

    # Create docker-compose.yml
    local docker_compose="$PROJECT_PATH/docker-compose.yml"
    cat > "$docker_compose" << 'EOF'
version: '3.8'

services:
  app:
    build: .
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      - DB_HOST=postgres
      - DB_PORT=5432
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      - postgres
      - redis
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=pern_app
      - POSTGRES_USER=pern_user
      - POSTGRES_PASSWORD=secure_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./sql/init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
EOF

    # Create nginx configuration
    local nginx_conf="$PROJECT_PATH/nginx.conf"
    cat > "$nginx_conf" << 'EOF'
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;

    # Performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    upstream app_backend {
        server app:5000;
    }

    server {
        listen 80;
        server_name localhost;

        # Redirect HTTP to HTTPS
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name localhost;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
        ssl_prefer_server_ciphers off;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

        # Proxy to app
        location / {
            proxy_pass http://app_backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }

        # Static files
        location /static/ {
            proxy_pass http://app_backend;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
EOF

    # Create SQL init file
    local sql_init="$PROJECT_PATH/sql/init.sql"
    create_directory "$(dirname "$sql_init")"
    cat > "$sql_init" << 'EOF'
-- Database initialization for production

-- Create users table
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

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    author_id INTEGER REFERENCES users(id),
    published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_posts_author_id ON posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_published ON posts(published);
EOF

    log_success "Docker support setup completed"
}

# Set up CI/CD templates
setup_ci_cd_templates() {
    log_info "Setting up CI/CD templates..."

    # GitHub Actions
    create_directory "$PROJECT_PATH/.github/workflows"

    local github_workflow="$PROJECT_PATH/.github/workflows/ci.yml"
    cat > "$github_workflow" << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]

    steps:
    - uses: actions/checkout@v3

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Run linter
      run: npm run lint

    - name: Run tests
      run: npm run test:coverage

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info
        flags: unittests
        name: codecov-umbrella

  build:
    runs-on: ubuntu-latest
    needs: test

    steps:
    - uses: actions/checkout@v3

    - name: Use Node.js 18.x
      uses: actions/setup-node@v3
      with:
        node-version: 18.x
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Build application
      run: npm run build

    - name: Upload build artifacts
      uses: actions/upload-artifact@v3
      with:
        name: build-files
        path: build/

  deploy:
    runs-on: ubuntu-latest
    needs: [test, build]
    if: github.ref == 'refs/heads/main'

    steps:
    - name: Deploy to production
      run: |
        echo "Deploying to production..."
        # Add your deployment commands here
EOF

    # GitLab CI
    local gitlab_ci="$PROJECT_PATH/.gitlab-ci.yml"
    cat > "$gitlab_ci" << 'EOF'
stages:
  - test
  - build
  - deploy

variables:
  NODE_VERSION: "18"

test:
  stage: test
  image: node:$NODE_VERSION
  script:
    - npm ci
    - npm run lint
    - npm run test:coverage
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
      junit: coverage/junit.xml

build:
  stage: build
  image: node:$NODE_VERSION
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - build/
    expire_in: 1 hour
  only:
    - main
    - develop

deploy:
  stage: deploy
  image: node:$NODE_VERSION
  script:
    - echo "Deploying to production..."
    # Add your deployment commands here
  environment: production
  only:
    - main
EOF

    log_success "CI/CD templates setup completed"
}

# Set up VS Code workspace settings
setup_vscode_settings() {
    if confirm "Set up VS Code workspace settings?"; then
        log_info "Setting up VS Code workspace settings..."

        # Create .vscode directory
        create_directory "$PROJECT_PATH/.vscode"

        # Create settings.json
        local vscode_settings="$PROJECT_PATH/.vscode/settings.json"
        cat > "$vscode_settings" << 'EOF'
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],
  "files.associations": {
    "*.js": "javascript",
    "*.jsx": "javascriptreact"
  },
  "emmet.includeLanguages": {
    "javascript": "javascriptreact"
  },
  "javascript.preferences.importModuleSpecifier": "relative",
  "typescript.preferences.importModuleSpecifier": "relative",
  "debug.node.autoAttach": "on",
  "files.exclude": {
    "**/node_modules": true,
    "**/build": true,
    "**/dist": true,
    "**/.git": false
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/build": true,
    "**/dist": true
  }
}
EOF

        # Create extensions.json
        local vscode_extensions="$PROJECT_PATH/.vscode/extensions.json"
        cat > "$vscode_extensions" << 'EOF'
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-json",
    "formulahendry.auto-rename-tag",
    "christian-kohler.path-intellisense",
    "ms-vscode.vscode-typescript-next",
    "humao.rest-client",
    "ms-vscode-remote.remote-containers",
    "ms-vscode.vscode-docker"
  ]
}
EOF

        log_success "VS Code workspace settings created"
    fi
}

# Install recommended VS Code extensions
install_vscode_extensions() {
    if confirm "Install recommended VS Code extensions?"; then
        log_info "Installing recommended VS Code extensions..."

        local extensions=(
            "esbenp.prettier-vscode"
            "dbaeumer.vscode-eslint"
            "bradlc.vscode-tailwindcss"
            "ms-vscode.vscode-json"
            "formulahendry.auto-rename-tag"
            "christian-kohler.path-intellisense"
            "ms-vscode.vscode-typescript-next"
            "humao.rest-client"
        )

        for extension in "${extensions[@]}"; do
            code --install-extension "$extension" 2>/dev/null || log_warning "Could not install extension: $extension"
        done

        log_success "VS Code extensions installation completed"
    fi
}

# Configure package.json scripts
configure_package_scripts() {
    if confirm "Configure package.json scripts?"; then
        log_info "Configuring package.json scripts..."

        if [[ -f "$PROJECT_PATH/package.json" ]]; then
            # Update package.json with additional scripts
            sed -i 's/"scripts": {/"scripts": {\n    "dev": "concurrently \"npm run server\" \"npm run client\"",\n    "server": "cd server && npm run dev",\n    "client": "cd client && npm run start",\n    "build": "npm run build:client && npm run build:server",\n    "build:client": "cd client && npm run build",\n    "build:server": "cd server && npm run build",\n    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",\n    "lint:fix": "eslint . --ext .js,.jsx,.ts,.tsx --fix",\n    "format": "prettier --write \"**/*.{js,jsx,ts,tsx,json,css,md}\"",\n    "docker:build": "docker build -t pern-app .",\n    "docker:run": "docker run -p 5000:5000 pern-app",\n    "docker:up": "docker-compose up -d",\n    "docker:down": "docker-compose down",/' "$PROJECT_PATH/package.json"

            log_success "Package.json scripts configured"
        fi
    fi
}