# Utility functions for PowerShell PERN Stack Setup

# Logging functions
function Write-LogInfo {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-LogSuccess {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-LogWarning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-LogError {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# User input functions
function Get-UserInput {
    param(
        [string]$Prompt,
        [string]$Validator = "",
        [string]$Default = ""
    )
    
    do {
        if ($Default) {
            $input = Read-Host "$Prompt [$Default]"
            if ([string]::IsNullOrEmpty($input)) {
                $input = $Default
            }
        } else {
            $input = Read-Host $Prompt
        }
        
        if ([string]::IsNullOrEmpty($input)) {
            Write-Host "Input cannot be empty. Please try again." -ForegroundColor Red
            continue
        }
        
        # Add validation logic here if needed
        return $input
    } while ($true)
}

function Get-UserConfirmation {
    param(
        [string]$Prompt,
        [bool]$Default = $false
    )
    
    $defaultText = if ($Default) { "Y/n" } else { "y/N" }
    $response = Read-Host "$Prompt [$defaultText]"
    
    if ([string]::IsNullOrEmpty($response)) {
        return $Default
    }
    
    return $response -match '^[Yy]'
}

# Directory functions
function New-Directory {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-LogInfo "Created directory: $Path"
    }
}

# File functions
function Backup-File {
    param([string]$FilePath)
    
    if (Test-Path $FilePath) {
        $backupPath = "$FilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $FilePath $backupPath
        Write-LogInfo "Backed up file: $FilePath -> $backupPath"
    }
}

# Git functions
function Initialize-Git {
    param([string]$ProjectPath)
    
    Set-Location $ProjectPath
    
    if (-not (Test-Path ".git")) {
        git init
        Write-LogSuccess "Initialized Git repository"
    } else {
        Write-LogInfo "Git repository already exists"
    }
}

function New-Gitignore {
    param(
        [string]$ProjectPath,
        [string]$Type = "node"
    )
    
    $gitignorePath = "$ProjectPath\.gitignore"
    
    $gitignoreContent = switch ($Type) {
        "node" {
            @"
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.*.local

# Build outputs
dist/
build/
*.tsbuildinfo

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage
coverage/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Temporary files
*.tmp
*.temp
"@
        }
        "fullstack" {
            @"
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.*.local

# Build outputs
dist/
build/
*.tsbuildinfo

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage
coverage/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Temporary files
*.tmp
*.temp
"@
        }
        default {
            @"
# Dependencies
node_modules/

# Environment variables
.env

# Build outputs
dist/
build/

# Logs
*.log

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
"@
        }
    }
    
    $gitignoreContent | Out-File -FilePath $gitignorePath -Encoding UTF8
    Write-LogSuccess "Created .gitignore file"
}

# Package.json functions
function New-PackageJson {
    param(
        [string]$ProjectPath,
        [string]$ProjectName,
        [string]$Type = "fullstack"
    )
    
    $packageJsonPath = "$ProjectPath\package.json"
    
    $packageJson = switch ($Type) {
        "fullstack" {
            @{
                name = $ProjectName
                version = "0.1.0"
                description = "PERN Fullstack Application"
                private = $true
                scripts = @{
                    dev = "concurrently `"npm run server:dev`" `"npm run client:dev`""
                    "server:dev" = "cd server && npm run dev"
                    "client:dev" = "cd client && npm start"
                    "server:build" = "cd server && npm run build"
                    "client:build" = "cd client && npm run build"
                    build = "npm run server:build && npm run client:build"
                    start = "npm run server:start"
                    "server:start" = "cd server && npm start"
                    test = "npm run server:test && npm run client:test"
                    "server:test" = "cd server && npm test"
                    "client:test" = "cd client && npm test"
                }
                devDependencies = @{
                    concurrently = "^7.6.0"
                }
                keywords = @("pern", "fullstack", "react", "express", "postgresql", "nodejs")
                author = ""
                license = "MIT"
            }
        }
        "api-only" {
            @{
                name = $ProjectName
                version = "0.1.0"
                description = "PERN API Server"
                main = "server/index.js"
                scripts = @{
                    start = "node server/index.js"
                    dev = "nodemon server/index.js"
                    test = "jest"
                    "test:watch" = "jest --watch"
                    "test:coverage" = "jest --coverage"
                }
                keywords = @("api", "express", "postgresql", "nodejs")
                author = ""
                license = "MIT"
            }
        }
        "microservices" {
            @{
                name = $ProjectName
                version = "0.1.0"
                description = "PERN Microservices Application"
                private = $true
                scripts = @{
                    dev = "docker-compose -f docker-compose.dev.yml up"
                    build = "docker-compose build"
                    start = "docker-compose up"
                    stop = "docker-compose down"
                    test = "npm run test:gateway && npm run test:auth && npm run test:user"
                    "test:gateway" = "cd api-gateway && npm test"
                    "test:auth" = "cd auth-service && npm test"
                    "test:user" = "cd user-service && npm test"
                }
                keywords = @("microservices", "docker", "api-gateway", "pern")
                author = ""
                license = "MIT"
            }
        }
        default {
            @{
                name = $ProjectName
                version = "0.1.0"
                description = "PERN Application"
                scripts = @{
                    start = "node index.js"
                    dev = "nodemon index.js"
                    test = "jest"
                }
                keywords = @("pern", "nodejs")
                author = ""
                license = "MIT"
            }
        }
    }
    
    $packageJson | ConvertTo-Json -Depth 3 | Out-File -FilePath $packageJsonPath -Encoding UTF8
    Write-LogSuccess "Created package.json file"
}

# Database functions
function New-DatabaseEnv {
    Write-LogInfo "Creating database environment configuration..."
    
    # Create .env file
    $envFile = "$Global:PROJECT_PATH\.env"
    if (Test-Path $envFile) {
        Backup-File $envFile
    }
    
    $envContent = @"
# Database Configuration
DB_HOST=$Global:DB_HOST
DB_PORT=$Global:DB_PORT
DB_NAME=$Global:DB_NAME
DB_USER=$Global:DB_USER
DB_PASSWORD=$Global:DB_PASSWORD

# Redis Configuration (if enabled)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Application Configuration
NODE_ENV=development
PORT=5000

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key
JWT_REFRESH_SECRET=your-super-secret-refresh-key

# CORS Configuration
CORS_ORIGIN=http://localhost:3000
"@
    
    $envContent | Out-File -FilePath $envFile -Encoding UTF8
    Write-LogSuccess "Created .env file"
}

# Installation functions
function Install-Dependencies {
    Write-LogInfo "Installing dependencies..."
    
    # Install root dependencies
    if (Test-Path "$Global:PROJECT_PATH\package.json") {
        Set-Location $Global:PROJECT_PATH
        npm install
    }
    
    # Install server dependencies
    if (Test-Path "$Global:PROJECT_PATH\server\package.json") {
        Set-Location "$Global:PROJECT_PATH\server"
        npm install
    }
    
    # Install client dependencies
    if (Test-Path "$Global:PROJECT_PATH\client\package.json") {
        Set-Location "$Global:PROJECT_PATH\client"
        npm install
    }
    
    Write-LogSuccess "Dependencies installed successfully"
}

# Progress functions
function Show-ProgressWithTime {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Message,
        [datetime]$StartTime
    )
    
    $elapsed = (Get-Date) - $StartTime
    $percentage = [math]::Round(($Current / $Total) * 100)
    
    Write-Progress -Activity "PERN Stack Setup" -Status $Message -PercentComplete $percentage -CurrentOperation "Step $Current of $Total"
    
    if ($Current -eq $Total) {
        Write-Progress -Activity "PERN Stack Setup" -Completed
    }
}

# Checkpoint functions
function New-Checkpoint {
    param([string]$Name)
    # Implementation for checkpoints
}

function Remove-Checkpoint {
    param([string]$Name)
    # Implementation for removing checkpoints
}

function Rollback-Setup {
    param([string]$Checkpoint)
    # Implementation for rollback
}

