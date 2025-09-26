# Database functions for PowerShell PERN Stack Setup

# Create database environment configuration
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

# Setup auto database configuration
function Set-AutoDatabase {
    Write-LogInfo "Setting up auto database configuration..."
    
    # Generate random credentials
    $Global:DB_NAME = "pern_$(Get-Random -Minimum 1000 -Maximum 9999)"
    $Global:DB_USER = "pern_user_$(Get-Random -Minimum 1000 -Maximum 9999)"
    $Global:DB_PASSWORD = [System.Web.Security.Membership]::GeneratePassword(16, 4)
    
    Write-LogInfo "Generated database credentials:"
    Write-LogInfo "Database: $Global:DB_NAME"
    Write-LogInfo "User: $Global:DB_USER"
    Write-LogInfo "Password: $Global:DB_PASSWORD"
    
    # Create database environment
    New-DatabaseEnv
    
    Write-LogSuccess "Auto database configuration completed"
}

# Setup custom database configuration
function Set-CustomDatabase {
    Write-LogInfo "Setting up custom database configuration..."
    
    # Get database details from user
    $Global:DB_NAME = Get-UserInput "Database name" "" "pern_app"
    $Global:DB_USER = Get-UserInput "Database user" "" "pern_user"
    $Global:DB_PASSWORD = Get-UserInput "Database password" "" ""
    $Global:DB_HOST = Get-UserInput "Database host" "" "localhost"
    $Global:DB_PORT = [int](Get-UserInput "Database port" "" "5432")
    
    # Create database environment
    New-DatabaseEnv
    
    Write-LogSuccess "Custom database configuration completed"
}

# Setup Docker database
function Set-DockerDatabase {
    Write-LogInfo "Setting up Docker database configuration..."
    
    # Generate random credentials
    $Global:DB_NAME = "pern_$(Get-Random -Minimum 1000 -Maximum 9999)"
    $Global:DB_USER = "pern_user_$(Get-Random -Minimum 1000 -Maximum 9999)"
    $Global:DB_PASSWORD = [System.Web.Security.Membership]::GeneratePassword(16, 4)
    $Global:DB_HOST = "localhost"
    $Global:DB_PORT = 5432
    
    # Create docker-compose.yml
    $dockerComposeContent = @"
version: '3.8'
services:
  postgres:
    image: postgres:15
    container_name: pern-postgres
    environment:
      POSTGRES_DB: $Global:DB_NAME
      POSTGRES_USER: $Global:DB_USER
      POSTGRES_PASSWORD: $Global:DB_PASSWORD
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: pern-redis
    ports:
      - "6379:6379"
    restart: unless-stopped

volumes:
  postgres_data:
"@
    
    $dockerComposePath = "$Global:PROJECT_PATH\docker-compose.yml"
    $dockerComposeContent | Out-File -FilePath $dockerComposePath -Encoding UTF8
    
    # Create database environment
    New-DatabaseEnv
    
    Write-LogSuccess "Docker database configuration completed"
    Write-LogInfo "Run 'docker-compose up -d' to start the database"
}

# Setup remote database
function Set-RemoteDatabase {
    Write-LogInfo "Setting up remote database configuration..."
    
    # Get remote database details
    $connectionString = Get-UserInput "Database connection string" "" ""
    
    if ([string]::IsNullOrEmpty($connectionString)) {
        Write-LogError "Connection string is required for remote database"
        return $false
    }
    
    # Parse connection string (basic parsing)
    $Global:DB_HOST = "remote-host"
    $Global:DB_PORT = 5432
    $Global:DB_NAME = "remote-db"
    $Global:DB_USER = "remote-user"
    $Global:DB_PASSWORD = "remote-password"
    
    # Create database environment with connection string
    $envFile = "$Global:PROJECT_PATH\.env"
    $envContent = @"
# Database Configuration
DATABASE_URL=$connectionString
DB_HOST=$Global:DB_HOST
DB_PORT=$Global:DB_PORT
DB_NAME=$Global:DB_NAME
DB_USER=$Global:DB_USER
DB_PASSWORD=$Global:DB_PASSWORD

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
    
    Write-LogSuccess "Remote database configuration completed"
}

# Test database connection
function Test-DatabaseConnection {
    param(
        [string]$Host = $Global:DB_HOST,
        [int]$Port = $Global:DB_PORT,
        [string]$Database = $Global:DB_NAME,
        [string]$Username = $Global:DB_USER,
        [string]$Password = $Global:DB_PASSWORD
    )
    
    Write-LogInfo "Testing database connection..."
    
    try {
        # Test connection using psql if available
        if (Test-CommandExists "psql") {
            $env:PGPASSWORD = $Password
            $result = psql -h $Host -p $Port -U $Username -d $Database -c "SELECT 1;" 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Database connection successful"
                return $true
            } else {
                Write-LogError "Database connection failed: $result"
                return $false
            }
        } else {
            Write-LogWarning "psql not found. Cannot test database connection."
            return $false
        }
    }
    catch {
        Write-LogError "Database connection test failed: $($_.Exception.Message)"
        return $false
    }
    finally {
        $env:PGPASSWORD = $null
    }
}

# Create database
function New-Database {
    param(
        [string]$DatabaseName = $Global:DB_NAME,
        [string]$Username = $Global:DB_USER,
        [string]$Password = $Global:DB_PASSWORD
    )
    
    Write-LogInfo "Creating database: $DatabaseName"
    
    try {
        if (Test-CommandExists "psql") {
            $env:PGPASSWORD = $Password
            
            # Create database
            psql -h $Global:DB_HOST -p $Global:DB_PORT -U $Username -d postgres -c "CREATE DATABASE $DatabaseName;" 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Database created successfully: $DatabaseName"
                return $true
            } else {
                Write-LogWarning "Database might already exist or creation failed"
                return $false
            }
        } else {
            Write-LogWarning "psql not found. Cannot create database."
            return $false
        }
    }
    catch {
        Write-LogError "Database creation failed: $($_.Exception.Message)"
        return $false
    }
    finally {
        $env:PGPASSWORD = $null
    }
}

# Create database user
function New-DatabaseUser {
    param(
        [string]$Username = $Global:DB_USER,
        [string]$Password = $Global:DB_PASSWORD
    )
    
    Write-LogInfo "Creating database user: $Username"
    
    try {
        if (Test-CommandExists "psql") {
            $env:PGPASSWORD = $Password
            
            # Create user
            psql -h $Global:DB_HOST -p $Global:DB_PORT -U postgres -d postgres -c "CREATE USER $Username WITH PASSWORD '$Password';" 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Database user created successfully: $Username"
                return $true
            } else {
                Write-LogWarning "Database user might already exist or creation failed"
                return $false
            }
        } else {
            Write-LogWarning "psql not found. Cannot create database user."
            return $false
        }
    }
    catch {
        Write-LogError "Database user creation failed: $($_.Exception.Message)"
        return $false
    }
    finally {
        $env:PGPASSWORD = $null
    }
}

# Setup database with migrations
function Set-DatabaseMigrations {
    Write-LogInfo "Setting up database migrations..."
    
    # Create migrations directory
    $migrationsDir = "$Global:PROJECT_PATH\server\migrations"
    New-Item -ItemType Directory -Path $migrationsDir -Force | Out-Null
    
    # Create initial migration
    $migrationFile = "$migrationsDir\001_initial_schema.sql"
    $migrationContent = @"
-- Initial schema migration
-- Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
"@
    
    $migrationContent | Out-File -FilePath $migrationFile -Encoding UTF8
    
    Write-LogSuccess "Database migrations setup completed"
    Write-LogInfo "Migration file created: $migrationFile"
}

# Run database migrations
function Invoke-DatabaseMigrations {
    Write-LogInfo "Running database migrations..."
    
    $migrationsDir = "$Global:PROJECT_PATH\server\migrations"
    
    if (-not (Test-Path $migrationsDir)) {
        Write-LogWarning "Migrations directory not found"
        return $false
    }
    
    $migrationFiles = Get-ChildItem -Path $migrationsDir -Filter "*.sql" | Sort-Object Name
    
    foreach ($migration in $migrationFiles) {
        Write-LogInfo "Running migration: $($migration.Name)"
        
        try {
            if (Test-CommandExists "psql") {
                $env:PGPASSWORD = $Global:DB_PASSWORD
                psql -h $Global:DB_HOST -p $Global:DB_PORT -U $Global:DB_USER -d $Global:DB_NAME -f $migration.FullName 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-LogSuccess "Migration completed: $($migration.Name)"
                } else {
                    Write-LogError "Migration failed: $($migration.Name)"
                    return $false
                }
            } else {
                Write-LogWarning "psql not found. Cannot run migrations."
                return $false
            }
        }
        catch {
            Write-LogError "Migration failed: $($_.Exception.Message)"
            return $false
        }
    }
    
    $env:PGPASSWORD = $null
    Write-LogSuccess "All migrations completed successfully"
    return $true
}

