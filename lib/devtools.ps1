# Development tools functions for PowerShell PERN Stack Setup

# Setup code quality tools
function Set-CodeQualityTools {
    Write-LogInfo "Setting up code quality tools..."
    
    # ESLint configuration
    if (Get-UserConfirmation "Setup ESLint?" $true) {
        Set-EslintConfig
    }
    
    # Prettier configuration
    if (Get-UserConfirmation "Setup Prettier?" $true) {
        Set-PrettierConfig
    }
    
    # EditorConfig
    if (Get-UserConfirmation "Setup EditorConfig?" $true) {
        Set-EditorConfig
    }
    
    Write-LogSuccess "Code quality tools setup completed"
}

# Setup ESLint configuration
function Set-EslintConfig {
    Write-LogInfo "Setting up ESLint..."
    
    # Root ESLint config
    $eslintConfig = @{
        env = @{
            browser = $true
            es2021 = $true
            node = $true
        }
        extends = @(
            "eslint:recommended",
            "@typescript-eslint/recommended"
        )
        parser = "@typescript-eslint/parser"
        parserOptions = @{
            ecmaVersion = "latest"
            sourceType = "module"
        }
        plugins = @("@typescript-eslint")
        rules = @{
            "no-unused-vars" = "warn"
            "no-console" = "warn"
            "@typescript-eslint/no-explicit-any" = "warn"
        }
    }
    
    $eslintConfigPath = "$Global:PROJECT_PATH\.eslintrc.json"
    $eslintConfig | ConvertTo-Json -Depth 3 | Out-File -FilePath $eslintConfigPath -Encoding UTF8
    
    # Server ESLint config
    if (Test-Path "$Global:PROJECT_PATH\server") {
        $serverEslintConfig = $eslintConfig.Clone()
        $serverEslintConfig.env.browser = $false
        $serverEslintConfig.env.node = $true
        
        $serverEslintPath = "$Global:PROJECT_PATH\server\.eslintrc.json"
        $serverEslintConfig | ConvertTo-Json -Depth 3 | Out-File -FilePath $serverEslintPath -Encoding UTF8
    }
    
    # Client ESLint config
    if (Test-Path "$Global:PROJECT_PATH\client") {
        $clientEslintConfig = $eslintConfig.Clone()
        $clientEslintConfig.extends += "plugin:react/recommended"
        $clientEslintConfig.plugins += "react"
        $clientEslintConfig.settings = @{
            react = @{
                version = "detect"
            }
        }
        
        $clientEslintPath = "$Global:PROJECT_PATH\client\.eslintrc.json"
        $clientEslintConfig | ConvertTo-Json -Depth 3 | Out-File -FilePath $clientEslintPath -Encoding UTF8
    }
    
    Write-LogSuccess "ESLint configuration created"
}

# Setup Prettier configuration
function Set-PrettierConfig {
    Write-LogInfo "Setting up Prettier..."
    
    $prettierConfig = @{
        semi = $true
        trailingComma = "es5"
        singleQuote = $true
        printWidth = 80
        tabWidth = 2
        useTabs = $false
    }
    
    $prettierConfigPath = "$Global:PROJECT_PATH\.prettierrc"
    $prettierConfig | ConvertTo-Json | Out-File -FilePath $prettierConfigPath -Encoding UTF8
    
    # Server Prettier config
    if (Test-Path "$Global:PROJECT_PATH\server") {
        $serverPrettierPath = "$Global:PROJECT_PATH\server\.prettierrc"
        Copy-Item $prettierConfigPath $serverPrettierPath
    }
    
    # Client Prettier config
    if (Test-Path "$Global:PROJECT_PATH\client") {
        $clientPrettierPath = "$Global:PROJECT_PATH\client\.prettierrc"
        Copy-Item $prettierConfigPath $clientPrettierPath
    }
    
    Write-LogSuccess "Prettier configuration created"
}

# Setup EditorConfig
function Set-EditorConfig {
    Write-LogInfo "Setting up EditorConfig..."
    
    $editorConfigContent = @"
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[*.{yml,yaml}]
indent_size = 2

[*.json]
indent_size = 2
"@
    
    $editorConfigPath = "$Global:PROJECT_PATH\.editorconfig"
    $editorConfigContent | Out-File -FilePath $editorConfigPath -Encoding UTF8
    
    Write-LogSuccess "EditorConfig created"
}

# Setup testing framework
function Set-TestingFramework {
    Write-LogInfo "Setting up testing framework..."
    
    # Jest configuration
    if (Get-UserConfirmation "Setup Jest?" $true) {
        Set-JestConfig
    }
    
    # React Testing Library
    if (Test-Path "$Global:PROJECT_PATH\client" -and (Get-UserConfirmation "Setup React Testing Library?" $true)) {
        Set-ReactTestingLibrary
    }
    
    # Supertest for API testing
    if (Test-Path "$Global:PROJECT_PATH\server" -and (Get-UserConfirmation "Setup Supertest for API testing?" $true)) {
        Set-Supertest
    }
    
    Write-LogSuccess "Testing framework setup completed"
}

# Setup Jest configuration
function Set-JestConfig {
    Write-LogInfo "Setting up Jest..."
    
    $jestConfig = @{
        testEnvironment = "node"
        roots = @("<rootDir>/src")
        testMatch = @(
            "**/__tests__/**/*.+(ts|tsx|js)",
            "**/*.(test|spec).+(ts|tsx|js)"
        )
        transform = @{
            "^.+\\.(ts|tsx)$" = "ts-jest"
        }
        collectCoverageFrom = @(
            "src/**/*.{ts,tsx}",
            "!src/**/*.d.ts"
        )
        coverageDirectory = "coverage"
        coverageReporters = @("text", "lcov", "html")
    }
    
    $jestConfigPath = "$Global:PROJECT_PATH\jest.config.js"
    $jestConfigJson = $jestConfig | ConvertTo-Json -Depth 3
    "module.exports = $jestConfigJson;" | Out-File -FilePath $jestConfigPath -Encoding UTF8
    
    # Server Jest config
    if (Test-Path "$Global:PROJECT_PATH\server") {
        $serverJestPath = "$Global:PROJECT_PATH\server\jest.config.js"
        Copy-Item $jestConfigPath $serverJestPath
    }
    
    # Client Jest config
    if (Test-Path "$Global:PROJECT_PATH\client") {
        $clientJestConfig = $jestConfig.Clone()
        $clientJestConfig.testEnvironment = "jsdom"
        $clientJestConfig.setupFilesAfterEnv = @("<rootDir>/src/setupTests.ts")
        
        $clientJestPath = "$Global:PROJECT_PATH\client\jest.config.js"
        $clientJestJson = $clientJestConfig | ConvertTo-Json -Depth 3
        "module.exports = $clientJestJson;" | Out-File -FilePath $clientJestPath -Encoding UTF8
    }
    
    Write-LogSuccess "Jest configuration created"
}

# Setup React Testing Library
function Set-ReactTestingLibrary {
    Write-LogInfo "Setting up React Testing Library..."
    
    # Create setupTests.ts
    $setupTestsContent = @"
import '@testing-library/jest-dom';
"@
    
    $setupTestsPath = "$Global:PROJECT_PATH\client\src\setupTests.ts"
    New-Item -ItemType Directory -Path (Split-Path $setupTestsPath -Parent) -Force | Out-Null
    $setupTestsContent | Out-File -FilePath $setupTestsPath -Encoding UTF8
    
    Write-LogSuccess "React Testing Library setup completed"
}

# Setup Supertest
function Set-Supertest {
    Write-LogInfo "Setting up Supertest..."
    
    # Create test helper
    $testHelperContent = @"
const request = require('supertest');
const app = require('../src/app');

module.exports = {
  request: request(app),
  app
};
"@
    
    $testHelperPath = "$Global:PROJECT_PATH\server\tests\helpers.js"
    New-Item -ItemType Directory -Path (Split-Path $testHelperPath -Parent) -Force | Out-Null
    $testHelperContent | Out-File -FilePath $testHelperPath -Encoding UTF8
    
    Write-LogSuccess "Supertest setup completed"
}

# Setup Git hooks
function Set-GitHooks {
    Write-LogInfo "Setting up Git hooks..."
    
    if (Get-UserConfirmation "Setup Husky for Git hooks?" $true) {
        Set-HuskyHooks
    }
    
    if (Get-UserConfirmation "Setup lint-staged?" $true) {
        Set-LintStaged
    }
    
    Write-LogSuccess "Git hooks setup completed"
}

# Setup Husky hooks
function Set-HuskyHooks {
    Write-LogInfo "Setting up Husky..."
    
    # Create .husky directory
    $huskyDir = "$Global:PROJECT_PATH\.husky"
    New-Item -ItemType Directory -Path $huskyDir -Force | Out-Null
    
    # Pre-commit hook
    $preCommitContent = @"
#!/bin/sh
. `$(dirname `$0)/_/husky.sh

npm run lint-staged
"@
    
    $preCommitPath = "$huskyDir\pre-commit"
    $preCommitContent | Out-File -FilePath $preCommitPath -Encoding UTF8
    
    # Pre-push hook
    $prePushContent = @"
#!/bin/sh
. `$(dirname `$0)/_/husky.sh

npm test
"@
    
    $prePushPath = "$huskyDir\pre-push"
    $prePushContent | Out-File -FilePath $prePushPath -Encoding UTF8
    
    Write-LogSuccess "Husky hooks created"
}

# Setup lint-staged
function Set-LintStaged {
    Write-LogInfo "Setting up lint-staged..."
    
    $lintStagedConfig = @{
        "*.{js,ts,tsx}" = @("eslint --fix", "prettier --write")
        "*.{json,md}" = "prettier --write"
    }
    
    $lintStagedPath = "$Global:PROJECT_PATH\.lintstagedrc.json"
    $lintStagedConfig | ConvertTo-Json -Depth 3 | Out-File -FilePath $lintStagedPath -Encoding UTF8
    
    Write-LogSuccess "lint-staged configuration created"
}

# Setup Docker support
function Set-DockerSupport {
    Write-LogInfo "Setting up Docker support..."
    
    if (Get-UserConfirmation "Create Dockerfile?" $true) {
        New-Dockerfile
    }
    
    if (Get-UserConfirmation "Create docker-compose.yml?" $true) {
        New-DockerCompose
    }
    
    if (Get-UserConfirmation "Create .dockerignore?" $true) {
        New-DockerIgnore
    }
    
    Write-LogSuccess "Docker support setup completed"
}

# Create Dockerfile
function New-Dockerfile {
    Write-LogInfo "Creating Dockerfile..."
    
    $dockerfileContent = @"
# Use Node.js LTS version
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY server/package*.json ./server/
COPY client/package*.json ./client/

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Expose port
EXPOSE 5000

# Start the application
CMD ["npm", "start"]
"@
    
    $dockerfilePath = "$Global:PROJECT_PATH\Dockerfile"
    $dockerfileContent | Out-File -FilePath $dockerfilePath -Encoding UTF8
    
    Write-LogSuccess "Dockerfile created"
}

# Create docker-compose.yml
function New-DockerCompose {
    Write-LogInfo "Creating docker-compose.yml..."
    
    $dockerComposeContent = @"
version: '3.8'

services:
  app:
    build: .
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: $Global:DB_NAME
      POSTGRES_USER: $Global:DB_USER
      POSTGRES_PASSWORD: $Global:DB_PASSWORD
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
"@
    
    $dockerComposePath = "$Global:PROJECT_PATH\docker-compose.yml"
    $dockerComposeContent | Out-File -FilePath $dockerComposePath -Encoding UTF8
    
    Write-LogSuccess "docker-compose.yml created"
}

# Create .dockerignore
function New-DockerIgnore {
    Write-LogInfo "Creating .dockerignore..."
    
    $dockerIgnoreContent = @"
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.nyc_output
.coverage
.coverage/
coverage/
*.log
logs
.DS_Store
.vscode
.idea
"@
    
    $dockerIgnorePath = "$Global:PROJECT_PATH\.dockerignore"
    $dockerIgnoreContent | Out-File -FilePath $dockerIgnorePath -Encoding UTF8
    
    Write-LogSuccess ".dockerignore created"
}

# Setup CI/CD templates
function Set-CiCdTemplates {
    Write-LogInfo "Setting up CI/CD templates..."
    
    if (Get-UserConfirmation "Create GitHub Actions workflow?" $true) {
        New-GitHubActions
    }
    
    if (Get-UserConfirmation "Create GitLab CI configuration?" $true) {
        New-GitLabCI
    }
    
    Write-LogSuccess "CI/CD templates setup completed"
}

# Create GitHub Actions workflow
function New-GitHubActions {
    Write-LogInfo "Creating GitHub Actions workflow..."
    
    $workflowContent = @"
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
    
    - name: Run linting
      run: npm run lint
    
    - name: Build application
      run: npm run build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to production
      run: echo "Deploy to production"
"@
    
    $workflowDir = "$Global:PROJECT_PATH\.github\workflows"
    New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null
    $workflowPath = "$workflowDir\ci.yml"
    $workflowContent | Out-File -FilePath $workflowPath -Encoding UTF8
    
    Write-LogSuccess "GitHub Actions workflow created"
}

# Create GitLab CI configuration
function New-GitLabCI {
    Write-LogInfo "Creating GitLab CI configuration..."
    
    $gitlabCiContent = @"
stages:
  - test
  - build
  - deploy

variables:
  NODE_VERSION: "18"

test:
  stage: test
  image: node:18-alpine
  services:
    - postgres:15
  variables:
    POSTGRES_DB: test_db
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
    DATABASE_URL: postgresql://postgres:postgres@postgres:5432/test_db
  before_script:
    - npm ci
  script:
    - npm test
    - npm run lint
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'

build:
  stage: build
  image: node:18-alpine
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

deploy:
  stage: deploy
  script:
    - echo "Deploy to production"
  only:
    - main
"@
    
    $gitlabCiPath = "$Global:PROJECT_PATH\.gitlab-ci.yml"
    $gitlabCiContent | Out-File -FilePath $gitlabCiPath -Encoding UTF8
    
    Write-LogSuccess "GitLab CI configuration created"
}

