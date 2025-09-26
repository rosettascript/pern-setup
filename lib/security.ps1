# Security functions for PowerShell PERN Stack Setup

# Generate secure configuration
function New-SecureConfig {
    Write-LogInfo "Generating secure configuration..."
    
    # Generate JWT secrets
    $jwtSecret = [System.Web.Security.Membership]::GeneratePassword(64, 8)
    $jwtRefreshSecret = [System.Web.Security.Membership]::GeneratePassword(64, 8)
    
    # Generate API key
    $apiKey = [System.Web.Security.Membership]::GeneratePassword(32, 4)
    
    # Generate random database password if not set
    if ([string]::IsNullOrEmpty($Global:DB_PASSWORD)) {
        $Global:DB_PASSWORD = [System.Web.Security.Membership]::GeneratePassword(16, 4)
    }
    
    # Update .env file
    $envFile = "$Global:PROJECT_PATH\.env"
    if (Test-Path $envFile) {
        $envContent = Get-Content $envFile -Raw
        
        # Replace or add secure values
        $envContent = $envContent -replace "JWT_SECRET=.*", "JWT_SECRET=$jwtSecret"
        $envContent = $envContent -replace "JWT_REFRESH_SECRET=.*", "JWT_REFRESH_SECRET=$jwtRefreshSecret"
        $envContent = $envContent -replace "API_KEY=.*", "API_KEY=$apiKey"
        $envContent = $envContent -replace "DB_PASSWORD=.*", "DB_PASSWORD=$Global:DB_PASSWORD"
        
        $envContent | Out-File -FilePath $envFile -Encoding UTF8
        
        Write-LogSuccess "Secure configuration generated"
        Write-LogInfo "JWT Secret: $jwtSecret"
        Write-LogInfo "JWT Refresh Secret: $jwtRefreshSecret"
        Write-LogInfo "API Key: $apiKey"
        Write-LogInfo "Database Password: $Global:DB_PASSWORD"
    }
}

# Configure CORS settings
function Set-CorsSettings {
    Write-LogInfo "Configuring CORS settings..."
    
    $env = Get-UserInput "Environment (development/production)" "" "development"
    $allowedOrigins = Get-UserInput "Allowed origins (comma-separated)" "" "http://localhost:3000"
    
    $corsOrigins = $allowedOrigins -split "," | ForEach-Object { $_.Trim() }
    
    # Update .env file
    $envFile = "$Global:PROJECT_PATH\.env"
    if (Test-Path $envFile) {
        $envContent = Get-Content $envFile -Raw
        
        # Update CORS settings
        $envContent = $envContent -replace "CORS_ORIGIN=.*", "CORS_ORIGIN=$($corsOrigins -join ',')"
        $envContent = $envContent -replace "NODE_ENV=.*", "NODE_ENV=$env"
        
        $envContent | Out-File -FilePath $envFile -Encoding UTF8
        
        Write-LogSuccess "CORS settings configured"
        Write-LogInfo "Environment: $env"
        Write-LogInfo "Allowed Origins: $($corsOrigins -join ', ')"
    }
}

# Setup SSL/TLS certificates
function Set-SslCertificates {
    Write-LogInfo "Setting up SSL/TLS certificates..."
    
    $certDir = "$Global:PROJECT_PATH\certs"
    New-Item -ItemType Directory -Path $certDir -Force | Out-Null
    
    # Generate self-signed certificate for development
    if (Get-UserConfirmation "Generate self-signed certificate for development?" $true) {
        try {
            # Create certificate using PowerShell
            $cert = New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsage DigitalSignature,KeyEncipherment -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1")
            
            # Export certificate
            $certPath = "$certDir\localhost.pfx"
            $certPassword = [System.Web.Security.Membership]::GeneratePassword(16, 4)
            
            $cert | Export-PfxCertificate -FilePath $certPath -Password (ConvertTo-SecureString -String $certPassword -Force -AsPlainText)
            
            # Export public key
            $publicCertPath = "$certDir\localhost.crt"
            $cert | Export-Certificate -FilePath $publicCertPath -Type CERT
            
            Write-LogSuccess "SSL certificate generated"
            Write-LogInfo "Certificate file: $certPath"
            Write-LogInfo "Certificate password: $certPassword"
            Write-LogInfo "Public certificate: $publicCertPath"
            
            # Update .env file with SSL settings
            $envFile = "$Global:PROJECT_PATH\.env"
            if (Test-Path $envFile) {
                $envContent = Get-Content $envFile -Raw
                $envContent += "`n# SSL Configuration`n"
                $envContent += "SSL_CERT_PATH=$certPath`n"
                $envContent += "SSL_CERT_PASSWORD=$certPassword`n"
                $envContent += "HTTPS_PORT=443`n"
                
                $envContent | Out-File -FilePath $envFile -Encoding UTF8
            }
        }
        catch {
            Write-LogError "Failed to generate SSL certificate: $($_.Exception.Message)"
        }
    }
}

# Configure logging levels
function Set-LoggingLevels {
    Write-LogInfo "Configuring logging levels..."
    
    $logLevel = Get-UserInput "Log level (debug/info/warn/error)" "" "info"
    $logFile = Get-UserInput "Log file path" "" "$Global:PROJECT_PATH\logs\app.log"
    
    # Create logs directory
    $logDir = Split-Path $logFile -Parent
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    
    # Update .env file
    $envFile = "$Global:PROJECT_PATH\.env"
    if (Test-Path $envFile) {
        $envContent = Get-Content $envFile -Raw
        
        # Add logging configuration
        $envContent += "`n# Logging Configuration`n"
        $envContent += "LOG_LEVEL=$logLevel`n"
        $envContent += "LOG_FILE=$logFile`n"
        
        $envContent | Out-File -FilePath $envFile -Encoding UTF8
        
        Write-LogSuccess "Logging configuration completed"
        Write-LogInfo "Log Level: $logLevel"
        Write-LogInfo "Log File: $logFile"
    }
}

# Custom security setup
function Set-CustomSecurity {
    Write-LogInfo "Custom security setup..."
    
    # Rate limiting
    if (Get-UserConfirmation "Configure rate limiting?" $true) {
        $rateLimitWindow = Get-UserInput "Rate limit window (minutes)" "" "15"
        $rateLimitMax = Get-UserInput "Max requests per window" "" "100"
        
        # Update .env file
        $envFile = "$Global:PROJECT_PATH\.env"
        if (Test-Path $envFile) {
            $envContent = Get-Content $envFile -Raw
            $envContent += "`n# Rate Limiting`n"
            $envContent += "RATE_LIMIT_WINDOW_MS=$([int]$rateLimitWindow * 60 * 1000)`n"
            $envContent += "RATE_LIMIT_MAX_REQUESTS=$rateLimitMax`n"
            
            $envContent | Out-File -FilePath $envFile -Encoding UTF8
        }
    }
    
    # Session configuration
    if (Get-UserConfirmation "Configure session settings?" $true) {
        $sessionSecret = [System.Web.Security.Membership]::GeneratePassword(32, 4)
        $sessionMaxAge = Get-UserInput "Session max age (hours)" "" "24"
        
        # Update .env file
        $envFile = "$Global:PROJECT_PATH\.env"
        if (Test-Path $envFile) {
            $envContent = Get-Content $envFile -Raw
            $envContent += "`n# Session Configuration`n"
            $envContent += "SESSION_SECRET=$sessionSecret`n"
            $envContent += "SESSION_MAX_AGE=$([int]$sessionMaxAge * 60 * 60 * 1000)`n"
            
            $envContent | Out-File -FilePath $envFile -Encoding UTF8
        }
    }
    
    # Security headers
    if (Get-UserConfirmation "Configure security headers?" $true) {
        $cspPolicy = Get-UserInput "Content Security Policy" "" "default-src 'self'"
        $hstsMaxAge = Get-UserInput "HSTS max age (seconds)" "" "31536000"
        
        # Update .env file
        $envFile = "$Global:PROJECT_PATH\.env"
        if (Test-Path $envFile) {
            $envContent = Get-Content $envFile -Raw
            $envContent += "`n# Security Headers`n"
            $envContent += "CSP_POLICY=$cspPolicy`n"
            $envContent += "HSTS_MAX_AGE=$hstsMaxAge`n"
            
            $envContent | Out-File -FilePath $envFile -Encoding UTF8
        }
    }
    
    Write-LogSuccess "Custom security configuration completed"
}

# Generate secure passwords
function New-SecurePassword {
    param(
        [int]$Length = 16,
        [int]$SpecialChars = 4
    )
    
    return [System.Web.Security.Membership]::GeneratePassword($Length, $SpecialChars)
}

# Validate password strength
function Test-PasswordStrength {
    param([string]$Password)
    
    $score = 0
    $feedback = @()
    
    # Length check
    if ($Password.Length -ge 8) {
        $score++
    } else {
        $feedback += "Password should be at least 8 characters long"
    }
    
    # Uppercase check
    if ($Password -cmatch "[A-Z]") {
        $score++
    } else {
        $feedback += "Password should contain uppercase letters"
    }
    
    # Lowercase check
    if ($Password -cmatch "[a-z]") {
        $score++
    } else {
        $feedback += "Password should contain lowercase letters"
    }
    
    # Number check
    if ($Password -match "[0-9]") {
        $score++
    } else {
        $feedback += "Password should contain numbers"
    }
    
    # Special character check
    if ($Password -match "[^a-zA-Z0-9]") {
        $score++
    } else {
        $feedback += "Password should contain special characters"
    }
    
    return @{
        Score = $score
        MaxScore = 5
        Feedback = $feedback
        IsStrong = $score -ge 4
    }
}

# Setup firewall rules (Windows)
function Set-FirewallRules {
    Write-LogInfo "Setting up firewall rules..."
    
    $os = Get-OperatingSystem
    
    if ($os -eq "windows") {
        try {
            # Allow Node.js through firewall
            if (Get-UserConfirmation "Allow Node.js through Windows Firewall?" $true) {
                New-NetFirewallRule -DisplayName "Node.js PERN App" -Direction Inbound -Protocol TCP -LocalPort 3000,5000 -Action Allow
                Write-LogSuccess "Firewall rules configured for Node.js"
            }
            
            # Allow PostgreSQL through firewall
            if (Get-UserConfirmation "Allow PostgreSQL through Windows Firewall?" $true) {
                New-NetFirewallRule -DisplayName "PostgreSQL PERN App" -Direction Inbound -Protocol TCP -LocalPort 5432 -Action Allow
                Write-LogSuccess "Firewall rules configured for PostgreSQL"
            }
        }
        catch {
            Write-LogWarning "Failed to configure firewall rules: $($_.Exception.Message)"
        }
    } else {
        Write-LogInfo "Firewall configuration not supported on this operating system"
    }
}

# Security audit
function Invoke-SecurityAudit {
    Write-LogInfo "Running security audit..."
    
    $issues = @()
    
    # Check for weak passwords
    if (-not [string]::IsNullOrEmpty($Global:DB_PASSWORD)) {
        $passwordCheck = Test-PasswordStrength $Global:DB_PASSWORD
        if (-not $passwordCheck.IsStrong) {
            $issues += "Database password is weak: $($passwordCheck.Feedback -join ', ')"
        }
    }
    
    # Check for default JWT secrets
    $envFile = "$Global:PROJECT_PATH\.env"
    if (Test-Path $envFile) {
        $envContent = Get-Content $envFile -Raw
        
        if ($envContent -match "JWT_SECRET=your-super-secret-jwt-key") {
            $issues += "JWT secret is using default value"
        }
        
        if ($envContent -match "JWT_REFRESH_SECRET=your-super-secret-refresh-key") {
            $issues += "JWT refresh secret is using default value"
        }
    }
    
    # Check for exposed sensitive data
    if (Test-Path "$Global:PROJECT_PATH\.env") {
        $envContent = Get-Content "$Global:PROJECT_PATH\.env" -Raw
        if ($envContent -match "password.*=") {
            $issues += "Sensitive data found in .env file - ensure it's in .gitignore"
        }
    }
    
    if ($issues.Count -gt 0) {
        Write-LogWarning "Security issues found:"
        foreach ($issue in $issues) {
            Write-LogWarning "  - $issue"
        }
    } else {
        Write-LogSuccess "No security issues found"
    }
    
    return $issues.Count -eq 0
}

