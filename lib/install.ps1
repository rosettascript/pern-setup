# Installation functions for PowerShell PERN Stack Setup

# Interactive setup function
function Start-InteractiveSetup {
    Write-LogInfo "Starting interactive setup..."
    
    $os = Get-OperatingSystem
    
    switch ($os) {
        "windows" {
            Start-WindowsInteractiveSetup
        }
        "macos" {
            Start-MacOSInteractiveSetup
        }
        "linux" {
            Start-LinuxInteractiveSetup
        }
        default {
            Write-LogError "Unsupported operating system"
            return $false
        }
    }
}

# Windows interactive setup
function Start-WindowsInteractiveSetup {
    Write-LogInfo "Windows interactive setup"
    
    # Check for package managers
    $hasChoco = Test-CommandExists "choco"
    $hasScoop = Test-CommandExists "scoop"
    
    if ($hasChoco) {
        Write-LogInfo "Using Chocolatey for package management"
        Install-NodeJSWindows "choco"
    } elseif ($hasScoop) {
        Write-LogInfo "Using Scoop for package management"
        Install-NodeJSWindows "scoop"
    } else {
        Write-LogWarning "No package manager found. Please install Node.js manually."
        Write-Host "Download from: https://nodejs.org/" -ForegroundColor Blue
    }
}

# macOS interactive setup
function Start-MacOSInteractiveSetup {
    Write-LogInfo "macOS interactive setup"
    
    if (Test-CommandExists "brew") {
        Write-LogInfo "Using Homebrew for package management"
        Install-NodeJSMacOS "brew"
    } else {
        Write-LogWarning "Homebrew not found. Please install Node.js manually."
        Write-Host "Download from: https://nodejs.org/" -ForegroundColor Blue
    }
}

# Linux interactive setup
function Start-LinuxInteractiveSetup {
    Write-LogInfo "Linux interactive setup"
    
    $dist = Get-LinuxDistribution
    
    switch ($dist) {
        "ubuntu" { Install-NodeJSLinux "ubuntu" }
        "debian" { Install-NodeJSLinux "debian" }
        "centos" { Install-NodeJSLinux "centos" }
        "rhel" { Install-NodeJSLinux "rhel" }
        "fedora" { Install-NodeJSLinux "fedora" }
        default {
            Write-LogWarning "Unsupported Linux distribution: $dist"
            Write-Host "Please install Node.js manually from: https://nodejs.org/" -ForegroundColor Blue
        }
    }
}

# Install Node.js on Windows
function Install-NodeJSWindows {
    param([string]$PackageManager)
    
    Write-LogInfo "Installing Node.js on Windows using $PackageManager"
    
    switch ($PackageManager) {
        "choco" {
            if (Get-UserConfirmation "Install Node.js via Chocolatey?" $true) {
                choco install nodejs -y
                Write-LogSuccess "Node.js installed via Chocolatey"
            }
        }
        "scoop" {
            if (Get-UserConfirmation "Install Node.js via Scoop?" $true) {
                scoop install nodejs
                Write-LogSuccess "Node.js installed via Scoop"
            }
        }
    }
}

# Install Node.js on macOS
function Install-NodeJSMacOS {
    param([string]$PackageManager)
    
    Write-LogInfo "Installing Node.js on macOS using $PackageManager"
    
    if ($PackageManager -eq "brew") {
        if (Get-UserConfirmation "Install Node.js via Homebrew?" $true) {
            brew install node
            Write-LogSuccess "Node.js installed via Homebrew"
        }
    }
}

# Install Node.js on Linux
function Install-NodeJSLinux {
    param([string]$Distribution)
    
    Write-LogInfo "Installing Node.js on Linux ($Distribution)"
    
    switch ($Distribution) {
        "ubuntu" {
            if (Get-UserConfirmation "Install Node.js on Ubuntu?" $true) {
                # Add NodeSource repository
                curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                sudo apt-get install -y nodejs
                Write-LogSuccess "Node.js installed on Ubuntu"
            }
        }
        "debian" {
            if (Get-UserConfirmation "Install Node.js on Debian?" $true) {
                curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                sudo apt-get install -y nodejs
                Write-LogSuccess "Node.js installed on Debian"
            }
        }
        "centos" {
            if (Get-UserConfirmation "Install Node.js on CentOS?" $true) {
                curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
                sudo yum install -y nodejs
                Write-LogSuccess "Node.js installed on CentOS"
            }
        }
        "rhel" {
            if (Get-UserConfirmation "Install Node.js on RHEL?" $true) {
                curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
                sudo yum install -y nodejs
                Write-LogSuccess "Node.js installed on RHEL"
            }
        }
        "fedora" {
            if (Get-UserConfirmation "Install Node.js on Fedora?" $true) {
                curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
                sudo dnf install -y nodejs
                Write-LogSuccess "Node.js installed on Fedora"
            }
        }
    }
}

# Install PostgreSQL
function Install-PostgreSQL {
    param([string]$Version = "latest")
    
    Write-LogInfo "Installing PostgreSQL $Version"
    
    $os = Get-OperatingSystem
    
    switch ($os) {
        "windows" {
            Install-PostgreSQLWindows $Version
        }
        "macos" {
            Install-PostgreSQLMacOS $Version
        }
        "linux" {
            Install-PostgreSQLLinux $Version
        }
    }
}

# Install PostgreSQL on Windows
function Install-PostgreSQLWindows {
    param([string]$Version)
    
    if (Test-CommandExists "choco") {
        if (Get-UserConfirmation "Install PostgreSQL via Chocolatey?" $true) {
            choco install postgresql -y
            Write-LogSuccess "PostgreSQL installed via Chocolatey"
        }
    } elseif (Test-CommandExists "scoop") {
        if (Get-UserConfirmation "Install PostgreSQL via Scoop?" $true) {
            scoop install postgresql
            Write-LogSuccess "PostgreSQL installed via Scoop"
        }
    } else {
        Write-LogWarning "No package manager found. Please install PostgreSQL manually."
        Write-Host "Download from: https://www.postgresql.org/download/windows/" -ForegroundColor Blue
    }
}

# Install PostgreSQL on macOS
function Install-PostgreSQLMacOS {
    param([string]$Version)
    
    if (Test-CommandExists "brew") {
        if (Get-UserConfirmation "Install PostgreSQL via Homebrew?" $true) {
            brew install postgresql
            Write-LogSuccess "PostgreSQL installed via Homebrew"
        }
    } else {
        Write-LogWarning "Homebrew not found. Please install PostgreSQL manually."
        Write-Host "Download from: https://www.postgresql.org/download/macosx/" -ForegroundColor Blue
    }
}

# Install PostgreSQL on Linux
function Install-PostgreSQLLinux {
    param([string]$Version)
    
    $dist = Get-LinuxDistribution
    
    switch ($dist) {
        "ubuntu" {
            if (Get-UserConfirmation "Install PostgreSQL on Ubuntu?" $true) {
                sudo apt-get update
                sudo apt-get install -y postgresql postgresql-contrib
                Write-LogSuccess "PostgreSQL installed on Ubuntu"
            }
        }
        "debian" {
            if (Get-UserConfirmation "Install PostgreSQL on Debian?" $true) {
                sudo apt-get update
                sudo apt-get install -y postgresql postgresql-contrib
                Write-LogSuccess "PostgreSQL installed on Debian"
            }
        }
        "centos" {
            if (Get-UserConfirmation "Install PostgreSQL on CentOS?" $true) {
                sudo yum install -y postgresql-server postgresql-contrib
                sudo postgresql-setup initdb
                Write-LogSuccess "PostgreSQL installed on CentOS"
            }
        }
        "rhel" {
            if (Get-UserConfirmation "Install PostgreSQL on RHEL?" $true) {
                sudo yum install -y postgresql-server postgresql-contrib
                sudo postgresql-setup initdb
                Write-LogSuccess "PostgreSQL installed on RHEL"
            }
        }
        "fedora" {
            if (Get-UserConfirmation "Install PostgreSQL on Fedora?" $true) {
                sudo dnf install -y postgresql-server postgresql-contrib
                sudo postgresql-setup --initdb
                Write-LogSuccess "PostgreSQL installed on Fedora"
            }
        }
    }
}

# Install Redis
function Install-Redis {
    Write-LogInfo "Installing Redis"
    
    $os = Get-OperatingSystem
    
    switch ($os) {
        "windows" {
            Install-RedisWindows
        }
        "macos" {
            Install-RedisMacOS
        }
        "linux" {
            Install-RedisLinux
        }
    }
}

# Install Redis on Windows
function Install-RedisWindows {
    if (Test-CommandExists "choco") {
        if (Get-UserConfirmation "Install Redis via Chocolatey?" $true) {
            choco install redis-64 -y
            Write-LogSuccess "Redis installed via Chocolatey"
        }
    } elseif (Test-CommandExists "scoop") {
        if (Get-UserConfirmation "Install Redis via Scoop?" $true) {
            scoop install redis
            Write-LogSuccess "Redis installed via Scoop"
        }
    } else {
        Write-LogWarning "No package manager found. Please install Redis manually."
        Write-Host "Download from: https://github.com/microsoftarchive/redis/releases" -ForegroundColor Blue
    }
}

# Install Redis on macOS
function Install-RedisMacOS {
    if (Test-CommandExists "brew") {
        if (Get-UserConfirmation "Install Redis via Homebrew?" $true) {
            brew install redis
            Write-LogSuccess "Redis installed via Homebrew"
        }
    } else {
        Write-LogWarning "Homebrew not found. Please install Redis manually."
        Write-Host "Download from: https://redis.io/download" -ForegroundColor Blue
    }
}

# Install Redis on Linux
function Install-RedisLinux {
    $dist = Get-LinuxDistribution
    
    switch ($dist) {
        "ubuntu" {
            if (Get-UserConfirmation "Install Redis on Ubuntu?" $true) {
                sudo apt-get update
                sudo apt-get install -y redis-server
                Write-LogSuccess "Redis installed on Ubuntu"
            }
        }
        "debian" {
            if (Get-UserConfirmation "Install Redis on Debian?" $true) {
                sudo apt-get update
                sudo apt-get install -y redis-server
                Write-LogSuccess "Redis installed on Debian"
            }
        }
        "centos" {
            if (Get-UserConfirmation "Install Redis on CentOS?" $true) {
                sudo yum install -y redis
                Write-LogSuccess "Redis installed on CentOS"
            }
        }
        "rhel" {
            if (Get-UserConfirmation "Install Redis on RHEL?" $true) {
                sudo yum install -y redis
                Write-LogSuccess "Redis installed on RHEL"
            }
        }
        "fedora" {
            if (Get-UserConfirmation "Install Redis on Fedora?" $true) {
                sudo dnf install -y redis
                Write-LogSuccess "Redis installed on Fedora"
            }
        }
    }
}

# Install Docker
function Install-Docker {
    Write-LogInfo "Installing Docker"
    
    $os = Get-OperatingSystem
    
    switch ($os) {
        "windows" {
            Install-DockerWindows
        }
        "macos" {
            Install-DockerMacOS
        }
        "linux" {
            Install-DockerLinux
        }
    }
}

# Install Docker on Windows
function Install-DockerWindows {
    if (Test-CommandExists "choco") {
        if (Get-UserConfirmation "Install Docker Desktop via Chocolatey?" $true) {
            choco install docker-desktop -y
            Write-LogSuccess "Docker Desktop installed via Chocolatey"
        }
    } else {
        Write-LogWarning "Chocolatey not found. Please install Docker Desktop manually."
        Write-Host "Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor Blue
    }
}

# Install Docker on macOS
function Install-DockerMacOS {
    if (Test-CommandExists "brew") {
        if (Get-UserConfirmation "Install Docker Desktop via Homebrew?" $true) {
            brew install --cask docker
            Write-LogSuccess "Docker Desktop installed via Homebrew"
        }
    } else {
        Write-LogWarning "Homebrew not found. Please install Docker Desktop manually."
        Write-Host "Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor Blue
    }
}

# Install Docker on Linux
function Install-DockerLinux {
    $dist = Get-LinuxDistribution
    
    switch ($dist) {
        "ubuntu" {
            if (Get-UserConfirmation "Install Docker on Ubuntu?" $true) {
                # Add Docker's official GPG key
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                
                # Add Docker repository
                echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                
                # Install Docker
                sudo apt-get update
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io
                
                # Add user to docker group
                sudo usermod -aG docker $USER
                
                Write-LogSuccess "Docker installed on Ubuntu"
            }
        }
        "debian" {
            if (Get-UserConfirmation "Install Docker on Debian?" $true) {
                # Similar to Ubuntu
                Write-LogSuccess "Docker installed on Debian"
            }
        }
        "centos" {
            if (Get-UserConfirmation "Install Docker on CentOS?" $true) {
                sudo yum install -y yum-utils
                sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                sudo yum install -y docker-ce docker-ce-cli containerd.io
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo usermod -aG docker $USER
                Write-LogSuccess "Docker installed on CentOS"
            }
        }
    }
}

