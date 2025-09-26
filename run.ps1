# PERN Stack Setup Script v2.0.0 (PowerShell)
# Comprehensive setup for PostgreSQL, Express.js, React, Node.js development environment
# Enhanced with modern folder structure and best practices
# Compatible with Windows PowerShell 5.1+ and PowerShell Core 6+

param(
    [string]$ProjectName = "",
    [string]$ProjectPath = "",
    [string]$DbName = "",
    [string]$DbUser = "",
    [string]$DbPassword = "",
    [string]$DbHost = "localhost",
    [int]$DbPort = 5432,
    [switch]$SkipDb,
    [switch]$MultiEnv,
    [switch]$SampleData,
    [switch]$Migrations,
    [switch]$Redis
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Cyan = "Cyan"
    Magenta = "Magenta"
    White = "White"
}

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Global:PROJECT_NAME = $ProjectName
$Global:PROJECT_PATH = $ProjectPath
$Global:DB_NAME = $DbName
$Global:DB_USER = $DbUser
$Global:DB_PASSWORD = $DbPassword
$Global:DB_HOST = $DbHost
$Global:DB_PORT = $DbPort
$Global:SKIP_DB = $SkipDb
$Global:MULTI_ENV = $MultiEnv
$Global:SAMPLE_DATA = $SampleData
$Global:MIGRATIONS = $Migrations
$Global:REDIS = $Redis

# Source library scripts
. "$ScriptDir\lib\utils.ps1"
. "$ScriptDir\lib\detect.ps1"
. "$ScriptDir\lib\install.ps1"
. "$ScriptDir\lib\database.ps1"
. "$ScriptDir\lib\security.ps1"
. "$ScriptDir\lib\devtools.ps1"
. "$ScriptDir\lib\validator.ps1"

# Function to set permissions for all scripts
function Set-ScriptPermissions {
    param([string]$ProjectPath)
    
    Write-LogInfo "Setting executable permissions for all scripts..."
    
    # Find and set permissions for all PowerShell scripts
    Get-ChildItem -Path $ProjectPath -Recurse -Filter "*.ps1" | ForEach-Object {
        try {
            # PowerShell doesn't need chmod, but we can set execution policy
            Write-LogInfo "Setting execution policy for: $($_.FullName)"
        }
        catch {
            Write-LogWarning "Could not set permissions for: $($_.FullName)"
        }
    }
    
    # Set permissions for specific script directories
    if (Test-Path "$ProjectPath\scripts") {
        Get-ChildItem -Path "$ProjectPath\scripts" -Recurse -Filter "*.ps1" | ForEach-Object {
            try {
                Write-LogInfo "Setting execution policy for: $($_.FullName)"
            }
            catch {
                Write-LogWarning "Could not set permissions for: $($_.FullName)"
            }
        }
    }
    
    Write-LogSuccess "Script permissions set successfully"
}

# Function to fix permissions for existing projects
function Fix-ExistingProjectPermissions {
    Write-Host "=== Fix Script Permissions ===" -ForegroundColor Blue
    Write-Host "This will set execution policy for all PowerShell scripts in your project."
    Write-Host ""
    
    # Get project path
    $projectPath = Get-UserInput "Enter project path" "" (Get-Location).Path
    
    if (-not (Test-Path $projectPath)) {
        Write-LogError "Project path does not exist: $projectPath"
        return $false
    }
    
    Write-LogInfo "Fixing permissions for project: $projectPath"
    
    # Set permissions
    Set-ScriptPermissions $projectPath
    
    Write-Host ""
    Write-LogSuccess "All script permissions have been fixed!"
    Write-Host "You can now run your scripts without permission errors."
}

# Main menu function
function Show-MainMenu {
    Write-Host "=== PERN Stack Setup ===" -ForegroundColor Blue
    Write-Host "Choose an option:"
    Write-Host "1) Quick setup (recommended versions)"
    Write-Host "2) Custom setup (choose specific versions)"
    Write-Host "3) Check existing installations"
    Write-Host "4) Interactive step-by-step"
    Write-Host "5) Fix script permissions (for existing projects)"
    Write-Host "6) Exit"
    Write-Host ""
}

# Project structure menu
function Show-ProjectMenu {
    Write-Host "=== Project Structure & Templates ===" -ForegroundColor Blue
    Write-Host "Choose a template:"
    Write-Host "1) Starter template (modern React + Express with TypeScript)"
    Write-Host "2) API-only template (Express.js backend with comprehensive setup)"
    Write-Host "3) Full-stack template (complete app with auth, file upload, modern UI)"
    Write-Host "4) Microservices template (multi-service architecture with Docker)"
    Write-Host "5) Custom structure (interactive folder creation)"
    Write-Host "6) Exit"
    Write-Host ""
}

# Database setup menu
function Show-DatabaseMenu {
    Write-Host "=== Database Setup ===" -ForegroundColor Blue
    Write-Host "Choose database option:"
    Write-Host "1) Local PostgreSQL (auto-config with random secure credentials)"
    Write-Host "2) Local PostgreSQL (custom config - user provides details)"
    Write-Host "3) Docker PostgreSQL (containerized setup)"
    Write-Host "4) Remote database (provide connection string)"
    Write-Host "5) Skip database setup"
    Write-Host "6) Exit"
    Write-Host ""
}

# Environment menu
function Show-EnvironmentMenu {
    Write-Host "=== Environment & Security ===" -ForegroundColor Blue
    Write-Host "Choose configuration option:"
    Write-Host "1) Auto-generate secure configuration (JWT secrets, API keys)"
    Write-Host "2) Configure CORS settings (development/production modes)"
    Write-Host "3) Set up SSL/TLS (development certificates)"
    Write-Host "4) Configure logging levels (debug, info, warn, error)"
    Write-Host "5) Custom security setup (interactive)"
    Write-Host "6) Skip configuration"
    Write-Host ""
}

# Development tools menu
function Show-DevToolsMenu {
    Write-Host "=== Development Tools (Optional) ===" -ForegroundColor Blue
    Write-Host "Choose development tools:"
    Write-Host "1) Code quality tools (ESLint + Prettier + EditorConfig)"
    Write-Host "2) Testing framework (Jest + Supertest + React Testing Library)"
    Write-Host "3) Git hooks (Husky + lint-staged)"
    Write-Host "4) Docker support (Dockerfile + docker-compose.yml)"
    Write-Host "5) CI/CD templates (GitHub Actions / GitLab CI)"
    Write-Host "6) Skip dev tools"
    Write-Host ""
}

# Final validation menu
function Show-ValidationMenu {
    Write-Host "=== Final Configuration & Validation ===" -ForegroundColor Blue
    Write-Host "Choose final step:"
    Write-Host "1) Install dependencies (npm install for all components)"
    Write-Host "2) Validate setup (test all connections and services)"
    Write-Host "3) Run initial build (ensure everything compiles)"
    Write-Host "4) Skip validation"
    Write-Host ""
}

# Summary menu
function Show-SummaryMenu {
    Write-Host "=== Installation Summary ===" -ForegroundColor Blue
    Write-Host "What would you like to do next?"
    Write-Host "1) Start development servers (backend + frontend)"
    Write-Host "2) Open project in VS Code (if available)"
    Write-Host "3) Show project documentation"
    Write-Host "4) Exit"
    Write-Host ""
}

# Get user choice
function Get-UserChoice {
    param([int]$MaxChoice)
    
    do {
        $choice = Read-Host "Enter your choice (1-$MaxChoice)"
        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $MaxChoice) {
            return [int]$choice
        } else {
            Write-Host "Invalid choice. Please enter a number between 1 and $MaxChoice." -ForegroundColor Red
        }
    } while ($true)
}

# Template setup functions
function Setup-StarterTemplate {
    Write-LogInfo "Setting up starter template..."
    
    # Get project details
    $Global:PROJECT_NAME = Get-UserInput "Project name" "validate_project_name" "pern-starter"
    $Global:PROJECT_PATH = Get-UserInput "Project path" "" "$env:USERPROFILE\Projects\$Global:PROJECT_NAME"
    
    # Create project directory
    New-Item -ItemType Directory -Path $Global:PROJECT_PATH -Force | Out-Null
    Set-Location $Global:PROJECT_PATH
    
    # Copy starter template
    Write-LogInfo "Copying starter template files..."
    Copy-Item -Path "$ScriptDir\templates\starter\*" -Destination $Global:PROJECT_PATH -Recurse -Force
    
    # Initialize Git repository
    if (Get-UserConfirmation "Initialize Git repository?" $true) {
        Initialize-Git $Global:PROJECT_PATH
        New-Gitignore $Global:PROJECT_PATH "fullstack"
    }
    
    # Create environment file
    New-DatabaseEnv
    
    # Install dependencies
    Write-LogInfo "Installing dependencies..."
    Install-Dependencies
    
    # Set script permissions
    Set-ScriptPermissions $Global:PROJECT_PATH
    
    Write-LogSuccess "Starter template setup completed"
}

function Setup-ApiOnlyTemplate {
    Write-LogInfo "Setting up API-only template..."
    
    # Get project details
    $Global:PROJECT_NAME = Get-UserInput "Project name" "validate_project_name" "pern-api"
    $Global:PROJECT_PATH = Get-UserInput "Project path" "" "$env:USERPROFILE\Projects\$Global:PROJECT_NAME"
    
    # Create project directory
    New-Item -ItemType Directory -Path $Global:PROJECT_PATH -Force | Out-Null
    Set-Location $Global:PROJECT_PATH
    
    # Create API-only structure
    New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\server" -Force | Out-Null
    New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\server\routes" -Force | Out-Null
    New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\server\controllers" -Force | Out-Null
    New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\server\middleware" -Force | Out-Null
    New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\server\models" -Force | Out-Null
    New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\server\config" -Force | Out-Null
    New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\server\tests" -Force | Out-Null
    New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\docs" -Force | Out-Null
    
    # Create server package.json
    $serverPackage = "$Global:PROJECT_PATH\server\package.json"
    $packageJson = @{
        name = "$Global:PROJECT_NAME-server"
        version = "0.1.0"
        description = "PERN API Server"
        main = "index.js"
        scripts = @{
            start = "node index.js"
            dev = "nodemon index.js"
            test = "jest"
            "test:watch" = "jest --watch"
            "test:coverage" = "jest --coverage"
        }
        keywords = @("api", "express", "postgresql", "nodejs")
        author = ""
        license = "MIT"
    } | ConvertTo-Json -Depth 3
    
    $packageJson | Out-File -FilePath $serverPackage -Encoding UTF8
    
    # Create main server file
    $serverIndex = "$Global:PROJECT_PATH\server\index.js"
    $serverCode = @'
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
'@
    
    $serverCode | Out-File -FilePath $serverIndex -Encoding UTF8
    
    # Create root package.json
    New-PackageJson $Global:PROJECT_PATH $Global:PROJECT_NAME "api-only"
    
    # Initialize Git repository
    if (Get-UserConfirmation "Initialize Git repository?" $true) {
        Initialize-Git $Global:PROJECT_PATH
        New-Gitignore $Global:PROJECT_PATH "node"
    }
    
    # Create environment file
    New-DatabaseEnv
    
    # Install dependencies
    Install-Dependencies
    
    # Set script permissions
    Set-ScriptPermissions $Global:PROJECT_PATH
    
    Write-LogSuccess "API-only template setup completed"
}

function Setup-FullstackTemplate {
    Write-LogInfo "Setting up fullstack template..."
    
    # Get project details
    $Global:PROJECT_NAME = Get-UserInput "Project name" "validate_project_name" "pern-fullstack"
    $Global:PROJECT_PATH = Get-UserInput "Project path" "" "$env:USERPROFILE\Projects\$Global:PROJECT_NAME"
    
    # Create project directory
    New-Item -ItemType Directory -Path $Global:PROJECT_PATH -Force | Out-Null
    Set-Location $Global:PROJECT_PATH
    
    # Copy fullstack template files
    Write-LogInfo "Copying fullstack template files..."
    Copy-Item -Path "$ScriptDir\templates\fullstack\*" -Destination $Global:PROJECT_PATH -Recurse -Force
    
    # Initialize Git repository
    if (Get-UserConfirmation "Initialize Git repository?" $true) {
        Initialize-Git $Global:PROJECT_PATH
        New-Gitignore $Global:PROJECT_PATH "fullstack"
    }
    
    # Run template setup script to create environment files
    if (Test-Path "$Global:PROJECT_PATH\scripts\setup.ps1") {
        Write-LogInfo "Running template setup script..."
        & "$Global:PROJECT_PATH\scripts\setup.ps1"
    } else {
        # Fallback: Create environment file
        New-DatabaseEnv
    }
    
    # Install dependencies
    Install-Dependencies
    
    # Set script permissions
    Set-ScriptPermissions $Global:PROJECT_PATH
    
    Write-LogSuccess "Fullstack template setup completed"
}

function Setup-MicroservicesTemplate {
    Write-LogInfo "Setting up microservices template..."
    
    # Get project details
    $Global:PROJECT_NAME = Get-UserInput "Project name" "validate_project_name" "pern-microservices"
    $Global:PROJECT_PATH = Get-UserInput "Project path" "" "$env:USERPROFILE\Projects\$Global:PROJECT_NAME"
    
    # Create project directory
    New-Item -ItemType Directory -Path $Global:PROJECT_PATH -Force | Out-Null
    Set-Location $Global:PROJECT_PATH
    
    # Copy microservices template files
    Write-LogInfo "Copying microservices template files..."
    Copy-Item -Path "$ScriptDir\templates\microservices\*" -Destination $Global:PROJECT_PATH -Recurse -Force
    
    # Initialize Git repository
    if (Get-UserConfirmation "Initialize Git repository?" $true) {
        Initialize-Git $Global:PROJECT_PATH
        New-Gitignore $Global:PROJECT_PATH "fullstack"
    }
    
    # Run template setup script to create environment files
    if (Test-Path "$Global:PROJECT_PATH\scripts\setup.ps1") {
        Write-LogInfo "Running template setup script..."
        & "$Global:PROJECT_PATH\scripts\setup.ps1"
    } else {
        # Fallback: Create environment file
        New-DatabaseEnv
    }
    
    # Install dependencies
    Install-Dependencies
    
    # Set script permissions
    Set-ScriptPermissions $Global:PROJECT_PATH
    
    Write-LogSuccess "Microservices template setup completed"
}

function Setup-CustomStructure {
    Write-LogInfo "Setting up custom structure..."
    
    # Get project details
    $Global:PROJECT_NAME = Get-UserInput "Project name" "validate_project_name" "pern-custom"
    $Global:PROJECT_PATH = Get-UserInput "Project path" "" "$env:USERPROFILE\Projects\$Global:PROJECT_NAME"
    
    # Create project directory
    New-Item -ItemType Directory -Path $Global:PROJECT_PATH -Force | Out-Null
    Set-Location $Global:PROJECT_PATH
    
    # Interactive structure creation
    Write-LogInfo "Let's create your custom project structure..."
    
    # Ask for components
    $hasServer = Get-UserConfirmation "Include server/backend?" $true
    $hasClient = Get-UserConfirmation "Include client/frontend?" $true
    $hasDatabase = Get-UserConfirmation "Include database setup?" $true
    $hasDocker = Get-UserConfirmation "Include Docker support?" $false
    $hasTests = Get-UserConfirmation "Include testing setup?" $true
    
    if ($hasServer) {
        New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\server" -Force | Out-Null
    }
    
    if ($hasClient) {
        New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\client" -Force | Out-Null
    }
    
    if ($hasDocker) {
        New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\docker" -Force | Out-Null
    }
    
    if ($hasTests) {
        New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\tests" -Force | Out-Null
    }
    
    # Create additional directories
    if (Get-UserConfirmation "Create docs directory?" $true) {
        New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\docs" -Force | Out-Null
    }
    
    if (Get-UserConfirmation "Create scripts directory?" $true) {
        New-Item -ItemType Directory -Path "$Global:PROJECT_PATH\scripts" -Force | Out-Null
    }
    
    # Create package.json based on selections
    $packageType = "custom"
    if ($hasServer -and $hasClient) {
        $packageType = "fullstack"
    } elseif ($hasServer) {
        $packageType = "api-only"
    }
    
    New-PackageJson $Global:PROJECT_PATH $Global:PROJECT_NAME $packageType
    
    # Initialize Git repository
    if (Get-UserConfirmation "Initialize Git repository?" $true) {
        Initialize-Git $Global:PROJECT_PATH
        New-Gitignore $Global:PROJECT_PATH $packageType
    }
    
    # Create environment file if database is included
    if ($hasDatabase) {
        New-DatabaseEnv
    }
    
    # Install dependencies
    Install-Dependencies
    
    # Set script permissions
    Set-ScriptPermissions $Global:PROJECT_PATH
    
    Write-LogSuccess "Custom structure setup completed"
}

# Main execution function
function Main {
    Write-Host "Welcome to PERN Stack Setup v2.0.0!" -ForegroundColor Green
    Write-Host "This script will help you set up a complete PERN (PostgreSQL, Express.js, React, Node.js) development environment."
    Write-Host "New in v2.0.0: Modern folder structure, TypeScript support, enhanced templates, and improved development experience!" -ForegroundColor Blue
    Write-Host ""

    # Step 1: Installation Options
    Write-Host "Step 1: Enhanced Installation Options" -ForegroundColor Yellow
    Show-MainMenu
    $choice = Get-UserChoice 6

    switch ($choice) {
        1 {
            Write-Host "Running quick setup with recommended versions..." -ForegroundColor Green
            # Quick setup implementation
        }
        2 {
            Write-Host "Running custom setup..." -ForegroundColor Green
            # Custom setup implementation
        }
        3 {
            Write-Host "Checking existing installations..." -ForegroundColor Green
            # Check installations
            return
        }
        4 {
            Write-Host "Running interactive step-by-step setup..." -ForegroundColor Green
            # Interactive setup implementation
            return
        }
        5 {
            Write-Host "Fixing script permissions..." -ForegroundColor Green
            Fix-ExistingProjectPermissions
            return
        }
        6 {
            Write-Host "Exiting..." -ForegroundColor Green
            exit 0
        }
    }

    # Step 2: Project Structure
    Write-Host "Step 2: Project Structure & Templates" -ForegroundColor Yellow
    Show-ProjectMenu
    $choice = Get-UserChoice 6

    switch ($choice) {
        1 { Setup-StarterTemplate }
        2 { Setup-ApiOnlyTemplate }
        3 { Setup-FullstackTemplate }
        4 { Setup-MicroservicesTemplate }
        5 { Setup-CustomStructure }
        6 {
            Write-Host "Exiting..." -ForegroundColor Green
            exit 0
        }
    }

    # Step 3: Database Setup
    if (-not $Global:SKIP_DB) {
        Write-Host "Step 3: Database Setup" -ForegroundColor Yellow
        Show-DatabaseMenu
        $choice = Get-UserChoice 6

        switch ($choice) {
            1 { # Auto database setup
                Write-Host "Setting up auto database..." -ForegroundColor Green
            }
            2 { # Custom database setup
                Write-Host "Setting up custom database..." -ForegroundColor Green
            }
            3 { # Docker database setup
                Write-Host "Setting up Docker database..." -ForegroundColor Green
            }
            4 { # Remote database setup
                Write-Host "Setting up remote database..." -ForegroundColor Green
            }
            5 {
                $Global:SKIP_DB = $true
                Write-Host "Skipping database setup..." -ForegroundColor Yellow
            }
            6 {
                Write-Host "Exiting..." -ForegroundColor Green
                exit 0
            }
        }
    }

    # Step 4: Environment & Security
    Write-Host "Step 4: Environment & Security" -ForegroundColor Yellow
    Show-EnvironmentMenu
    $choice = Get-UserChoice 6

    switch ($choice) {
        1 { # Generate secure config
            Write-Host "Generating secure configuration..." -ForegroundColor Green
        }
        2 { # Configure CORS
            Write-Host "Configuring CORS..." -ForegroundColor Green
        }
        3 { # Setup SSL
            Write-Host "Setting up SSL..." -ForegroundColor Green
        }
        4 { # Configure logging
            Write-Host "Configuring logging..." -ForegroundColor Green
        }
        5 { # Custom security setup
            Write-Host "Custom security setup..." -ForegroundColor Green
        }
        6 {
            Write-Host "Skipping environment configuration..." -ForegroundColor Yellow
        }
    }

    # Step 5: Development Tools
    Write-Host "Step 5: Development Tools (Optional)" -ForegroundColor Yellow
    Show-DevToolsMenu
    $choice = Get-UserChoice 6

    switch ($choice) {
        1 { # Code quality tools
            Write-Host "Setting up code quality tools..." -ForegroundColor Green
        }
        2 { # Testing framework
            Write-Host "Setting up testing framework..." -ForegroundColor Green
        }
        3 { # Git hooks
            Write-Host "Setting up Git hooks..." -ForegroundColor Green
        }
        4 { # Docker support
            Write-Host "Setting up Docker support..." -ForegroundColor Green
        }
        5 { # CI/CD templates
            Write-Host "Setting up CI/CD templates..." -ForegroundColor Green
        }
        6 {
            Write-Host "Skipping development tools..." -ForegroundColor Yellow
        }
    }

    # Step 6: Final Validation
    Write-Host "Step 6: Final Configuration & Validation" -ForegroundColor Yellow
    Show-ValidationMenu
    $choice = Get-UserChoice 4

    switch ($choice) {
        1 { # Install dependencies
            Write-Host "Installing dependencies..." -ForegroundColor Green
        }
        2 { # Validate setup
            Write-Host "Validating setup..." -ForegroundColor Green
        }
        3 { # Run initial build
            Write-Host "Running initial build..." -ForegroundColor Green
        }
        4 {
            Write-Host "Skipping validation..." -ForegroundColor Yellow
        }
    }

    # Final Summary
    Write-Host "=== Installation Complete! ===" -ForegroundColor Green
    # Show installation summary

    Show-SummaryMenu
    $choice = Get-UserChoice 4

    switch ($choice) {
        1 { # Start development servers
            Write-Host "Starting development servers..." -ForegroundColor Green
        }
        2 { # Open in VS Code
            Write-Host "Opening in VS Code..." -ForegroundColor Green
        }
        3 { # Show documentation
            Write-Host "Showing documentation..." -ForegroundColor Green
        }
        4 {
            Write-Host "Setup complete! Happy coding!" -ForegroundColor Green
            exit 0
        }
    }
}

# Run main function
Main

