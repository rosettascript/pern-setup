# Validation functions for PowerShell PERN Stack Setup

# Validate project name
function Test-ProjectName {
    param([string]$Name)
    
    if ([string]::IsNullOrEmpty($Name)) {
        return $false
    }
    
    # Check for valid characters (alphanumeric, hyphens, underscores)
    if ($Name -notmatch '^[a-zA-Z0-9_-]+$') {
        return $false
    }
    
    # Check length
    if ($Name.Length -lt 2 -or $Name.Length -gt 50) {
        return $false
    }
    
    # Check for reserved names
    $reservedNames = @("node_modules", "package", "npm", "yarn", "git", "test", "src", "lib", "bin")
    if ($reservedNames -contains $Name.ToLower()) {
        return $false
    }
    
    return $true
}

# Validate project path
function Test-ProjectPath {
    param([string]$Path)
    
    if ([string]::IsNullOrEmpty($Path)) {
        return $false
    }
    
    # Check if path is valid
    try {
        $resolvedPath = Resolve-Path $Path -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Validate database configuration
function Test-DatabaseConfig {
    param(
        [string]$Host = $Global:DB_HOST,
        [int]$Port = $Global:DB_PORT,
        [string]$Name = $Global:DB_NAME,
        [string]$User = $Global:DB_USER,
        [string]$Password = $Global:DB_PASSWORD
    )
    
    $errors = @()
    
    # Validate host
    if ([string]::IsNullOrEmpty($Host)) {
        $errors += "Database host is required"
    }
    
    # Validate port
    if ($Port -lt 1 -or $Port -gt 65535) {
        $errors += "Database port must be between 1 and 65535"
    }
    
    # Validate database name
    if ([string]::IsNullOrEmpty($Name)) {
        $errors += "Database name is required"
    } elseif ($Name -notmatch '^[a-zA-Z0-9_]+$') {
        $errors += "Database name can only contain letters, numbers, and underscores"
    }
    
    # Validate user
    if ([string]::IsNullOrEmpty($User)) {
        $errors += "Database user is required"
    }
    
    # Validate password
    if ([string]::IsNullOrEmpty($Password)) {
        $errors += "Database password is required"
    } elseif ($Password.Length -lt 8) {
        $errors += "Database password must be at least 8 characters long"
    }
    
    return @{
        IsValid = $errors.Count -eq 0
        Errors = $errors
    }
}

# Validate environment variables
function Test-EnvironmentVariables {
    $envFile = "$Global:PROJECT_PATH\.env"
    
    if (-not (Test-Path $envFile)) {
        return @{
            IsValid = $false
            Errors = @("Environment file not found")
        }
    }
    
    $errors = @()
    $envContent = Get-Content $envFile -Raw
    
    # Check for required variables
    $requiredVars = @("NODE_ENV", "PORT", "DB_HOST", "DB_PORT", "DB_NAME", "DB_USER", "DB_PASSWORD")
    
    foreach ($var in $requiredVars) {
        if ($envContent -notmatch "$var=") {
            $errors += "Required environment variable missing: $var"
        }
    }
    
    # Check for default values that should be changed
    if ($envContent -match "JWT_SECRET=your-super-secret-jwt-key") {
        $errors += "JWT_SECRET is using default value - should be changed"
    }
    
    if ($envContent -match "JWT_REFRESH_SECRET=your-super-secret-refresh-key") {
        $errors += "JWT_REFRESH_SECRET is using default value - should be changed"
    }
    
    return @{
        IsValid = $errors.Count -eq 0
        Errors = $errors
    }
}

# Validate package.json
function Test-PackageJson {
    $packageJsonPath = "$Global:PROJECT_PATH\package.json"
    
    if (-not (Test-Path $packageJsonPath)) {
        return @{
            IsValid = $false
            Errors = @("package.json not found")
        }
    }
    
    $errors = @()
    
    try {
        $packageJson = Get-Content $packageJsonPath -Raw | ConvertFrom-Json
        
        # Check required fields
        if ([string]::IsNullOrEmpty($packageJson.name)) {
            $errors += "package.json missing 'name' field"
        }
        
        if ([string]::IsNullOrEmpty($packageJson.version)) {
            $errors += "package.json missing 'version' field"
        }
        
        # Check scripts
        if (-not $packageJson.scripts) {
            $errors += "package.json missing 'scripts' field"
        } else {
            $requiredScripts = @("start", "dev", "test")
            foreach ($script in $requiredScripts) {
                if (-not $packageJson.scripts.$script) {
                    $errors += "package.json missing required script: $script"
                }
            }
        }
        
        # Check dependencies
        if (-not $packageJson.dependencies -and -not $packageJson.devDependencies) {
            $errors += "package.json has no dependencies"
        }
        
    }
    catch {
        $errors += "Invalid JSON in package.json: $($_.Exception.Message)"
    }
    
    return @{
        IsValid = $errors.Count -eq 0
        Errors = $errors
    }
}

# Validate Git repository
function Test-GitRepository {
    $gitDir = "$Global:PROJECT_PATH\.git"
    
    if (-not (Test-Path $gitDir)) {
        return @{
            IsValid = $false
            Errors = @("Git repository not initialized")
        }
    }
    
    $errors = @()
    
    # Check for .gitignore
    if (-not (Test-Path "$Global:PROJECT_PATH\.gitignore")) {
        $errors += ".gitignore file not found"
    }
    
    # Check for sensitive files in git
    $sensitiveFiles = @(".env", "node_modules", "*.log")
    foreach ($file in $sensitiveFiles) {
        $gitStatus = git status --porcelain 2>&1
        if ($gitStatus -match $file) {
            $errors += "Sensitive file tracked in git: $file"
        }
    }
    
    return @{
        IsValid = $errors.Count -eq 0
        Errors = $errors
    }
}

# Validate Docker configuration
function Test-DockerConfig {
    $errors = @()
    
    # Check for Dockerfile
    if (-not (Test-Path "$Global:PROJECT_PATH\Dockerfile")) {
        $errors += "Dockerfile not found"
    }
    
    # Check for docker-compose.yml
    if (-not (Test-Path "$Global:PROJECT_PATH\docker-compose.yml")) {
        $errors += "docker-compose.yml not found"
    }
    
    # Check for .dockerignore
    if (-not (Test-Path "$Global:PROJECT_PATH\.dockerignore")) {
        $errors += ".dockerignore not found"
    }
    
    return @{
        IsValid = $errors.Count -eq 0
        Errors = $errors
    }
}

# Validate testing setup
function Test-TestingSetup {
    $errors = @()
    
    # Check for Jest configuration
    $jestConfigs = @(
        "$Global:PROJECT_PATH\jest.config.js",
        "$Global:PROJECT_PATH\server\jest.config.js",
        "$Global:PROJECT_PATH\client\jest.config.js"
    )
    
    $hasJestConfig = $false
    foreach ($config in $jestConfigs) {
        if (Test-Path $config) {
            $hasJestConfig = $true
            break
        }
    }
    
    if (-not $hasJestConfig) {
        $errors += "Jest configuration not found"
    }
    
    # Check for test files
    $testFiles = Get-ChildItem -Path $Global:PROJECT_PATH -Recurse -Filter "*.test.*" -ErrorAction SilentlyContinue
    if ($testFiles.Count -eq 0) {
        $errors += "No test files found"
    }
    
    return @{
        IsValid = $errors.Count -eq 0
        Errors = $errors
    }
}

# Validate code quality setup
function Test-CodeQualitySetup {
    $errors = @()
    
    # Check for ESLint configuration
    $eslintConfigs = @(
        "$Global:PROJECT_PATH\.eslintrc.json",
        "$Global:PROJECT_PATH\server\.eslintrc.json",
        "$Global:PROJECT_PATH\client\.eslintrc.json"
    )
    
    $hasEslintConfig = $false
    foreach ($config in $eslintConfigs) {
        if (Test-Path $config) {
            $hasEslintConfig = $true
            break
        }
    }
    
    if (-not $hasEslintConfig) {
        $errors += "ESLint configuration not found"
    }
    
    # Check for Prettier configuration
    if (-not (Test-Path "$Global:PROJECT_PATH\.prettierrc")) {
        $errors += "Prettier configuration not found"
    }
    
    # Check for EditorConfig
    if (-not (Test-Path "$Global:PROJECT_PATH\.editorconfig")) {
        $errors += "EditorConfig not found"
    }
    
    return @{
        IsValid = $errors.Count -eq 0
        Errors = $errors
    }
}

# Comprehensive validation
function Test-ProjectValidation {
    Write-LogInfo "Running comprehensive project validation..."
    
    $allErrors = @()
    $warnings = @()
    
    # Validate project structure
    $structureValidation = Test-ProjectStructure
    if (-not $structureValidation.IsValid) {
        $allErrors += $structureValidation.Errors
    }
    
    # Validate environment variables
    $envValidation = Test-EnvironmentVariables
    if (-not $envValidation.IsValid) {
        $allErrors += $envValidation.Errors
    }
    
    # Validate package.json
    $packageValidation = Test-PackageJson
    if (-not $packageValidation.IsValid) {
        $allErrors += $packageValidation.Errors
    }
    
    # Validate Git repository
    $gitValidation = Test-GitRepository
    if (-not $gitValidation.IsValid) {
        $warnings += $gitValidation.Errors
    }
    
    # Validate database configuration
    $dbValidation = Test-DatabaseConfig
    if (-not $dbValidation.IsValid) {
        $allErrors += $dbValidation.Errors
    }
    
    # Display results
    if ($allErrors.Count -gt 0) {
        Write-LogError "Validation failed with $($allErrors.Count) errors:"
        foreach ($error in $allErrors) {
            Write-LogError "  - $error"
        }
    }
    
    if ($warnings.Count -gt 0) {
        Write-LogWarning "Validation completed with $($warnings.Count) warnings:"
        foreach ($warning in $warnings) {
            Write-LogWarning "  - $warning"
        }
    }
    
    if ($allErrors.Count -eq 0 -and $warnings.Count -eq 0) {
        Write-LogSuccess "All validations passed!"
    }
    
    return @{
        IsValid = $allErrors.Count -eq 0
        Errors = $allErrors
        Warnings = $warnings
    }
}

# Validate project structure
function Test-ProjectStructure {
    $errors = @()
    
    # Check for required directories
    $requiredDirs = @("server", "client")
    foreach ($dir in $requiredDirs) {
        if (-not (Test-Path "$Global:PROJECT_PATH\$dir")) {
            $errors += "Required directory missing: $dir"
        }
    }
    
    # Check for package.json files
    $packageFiles = @(
        "$Global:PROJECT_PATH\package.json",
        "$Global:PROJECT_PATH\server\package.json",
        "$Global:PROJECT_PATH\client\package.json"
    )
    
    foreach ($packageFile in $packageFiles) {
        if (-not (Test-Path $packageFile)) {
            $errors += "Required package.json missing: $packageFile"
        }
    }
    
    return @{
        IsValid = $errors.Count -eq 0
        Errors = $errors
    }
}

# Validate system requirements
function Test-SystemRequirements {
    $errors = @()
    
    # Check Node.js version
    if (Test-CommandExists "node") {
        $nodeVersion = node --version
        $majorVersion = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
        if ($majorVersion -lt 16) {
            $errors += "Node.js version 16 or higher required (found: $nodeVersion)"
        }
    } else {
        $errors += "Node.js not found"
    }
    
    # Check npm version
    if (Test-CommandExists "npm") {
        $npmVersion = npm --version
        Write-LogInfo "npm version: $npmVersion"
    } else {
        $errors += "npm not found"
    }
    
    # Check Git
    if (-not (Test-CommandExists "git")) {
        $errors += "Git not found"
    }
    
    return @{
        IsValid = $errors.Count -eq 0
        Errors = $errors
    }
}

