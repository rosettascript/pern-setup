# System detection and validation functions for PowerShell

# Detect operating system
function Get-OperatingSystem {
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        return "windows"
    } elseif ($IsMacOS) {
        return "macos"
    } elseif ($IsLinux) {
        return "linux"
    } else {
        return "unknown"
    }
}

# Detect Windows version
function Get-WindowsVersion {
    if ($IsWindows) {
        $os = Get-WmiObject -Class Win32_OperatingSystem
        return $os.Caption
    }
    return "Not Windows"
}

# Check system requirements
function Test-SystemRequirements {
    Write-LogInfo "Checking system requirements..."
    
    $os = Get-OperatingSystem
    $issues = 0
    
    switch ($os) {
        "windows" {
            $issues += Test-WindowsRequirements
        }
        "macos" {
            $issues += Test-MacOSRequirements
        }
        "linux" {
            $issues += Test-LinuxRequirements
        }
        default {
            Write-LogWarning "Unsupported operating system: $os"
            $issues++
        }
    }
    
    return $issues -eq 0
}

# Check Windows-specific requirements
function Test-WindowsRequirements {
    Write-LogInfo "Detected Windows"
    
    # Check PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    Write-LogInfo "PowerShell version: $psVersion"
    
    if ($psVersion.Major -lt 5) {
        Write-LogWarning "PowerShell 5.1 or higher recommended"
    }
    
    # Check if we're in WSL
    if ($env:WSL_DISTRO_NAME) {
        Write-LogInfo "Running in WSL: $env:WSL_DISTRO_NAME"
    }
    
    # Check for package managers
    $packageManagers = @()
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        $packageManagers += "Chocolatey"
        Write-LogInfo "Chocolatey package manager found"
    }
    
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $packageManagers += "Scoop"
        Write-LogInfo "Scoop package manager found"
    }
    
    if ($packageManagers.Count -eq 0) {
        Write-LogWarning "No package manager found. Consider installing Chocolatey or Scoop."
    }
    
    # Check available disk space (at least 2GB free)
    $drive = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
    $freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 2)
    
    if ($freeSpaceGB -lt 2) {
        Write-LogWarning "Low disk space: $freeSpaceGB GB available (2GB recommended)"
    } else {
        Write-LogInfo "Available disk space: $freeSpaceGB GB"
    }
    
    return 0
}

# Check macOS-specific requirements
function Test-MacOSRequirements {
    Write-LogInfo "Detected macOS"
    
    # Check macOS version
    $macosVersion = (sw_vers -productVersion)
    Write-LogInfo "macOS version: $macosVersion"
    
    # Check for Homebrew
    if (Get-Command brew -ErrorAction SilentlyContinue) {
        Write-LogInfo "Homebrew package manager found"
    } else {
        Write-LogWarning "Homebrew not found. Consider installing it for easier package management."
    }
    
    # Check available disk space
    $diskInfo = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
    $freeSpaceGB = [math]::Round($diskInfo.FreeSpace / 1GB, 2)
    
    if ($freeSpaceGB -lt 2) {
        Write-LogWarning "Low disk space: $freeSpaceGB GB available (2GB recommended)"
    } else {
        Write-LogInfo "Available disk space: $freeSpaceGB GB"
    }
    
    return 0
}

# Check Linux-specific requirements
function Test-LinuxRequirements {
    Write-LogInfo "Detected Linux"
    
    # Detect Linux distribution
    $dist = Get-LinuxDistribution
    Write-LogInfo "Linux distribution: $dist"
    
    # Check available disk space
    $diskInfo = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
    $freeSpaceGB = [math]::Round($diskInfo.FreeSpace / 1GB, 2)
    
    if ($freeSpaceGB -lt 2) {
        Write-LogWarning "Low disk space: $freeSpaceGB GB available (2GB recommended)"
    } else {
        Write-LogInfo "Available disk space: $freeSpaceGB GB"
    }
    
    return 0
}

# Detect Linux distribution
function Get-LinuxDistribution {
    if (Get-Command lsb_release -ErrorAction SilentlyContinue) {
        return (lsb_release -si).ToLower()
    } elseif (Test-Path "/etc/os-release") {
        $content = Get-Content "/etc/os-release"
        $id = ($content | Where-Object { $_ -match "^ID=" }) -replace "ID=", ""
        return $id.Trim('"')
    } else {
        return "unknown"
    }
}

# Check existing installations
function Test-ExistingInstallations {
    Write-LogInfo "Checking existing installations..."
    
    $installations = @{}
    
    # Check Node.js
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $nodeVersion = node --version
        $installations.NodeJS = $nodeVersion
        Write-LogInfo "Node.js found: $nodeVersion"
    } else {
        Write-LogInfo "Node.js not found"
    }
    
    # Check npm
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        $npmVersion = npm --version
        $installations.npm = $npmVersion
        Write-LogInfo "npm found: $npmVersion"
    } else {
        Write-LogInfo "npm not found"
    }
    
    # Check Git
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitVersion = git --version
        $installations.Git = $gitVersion
        Write-LogInfo "Git found: $gitVersion"
    } else {
        Write-LogInfo "Git not found"
    }
    
    # Check PostgreSQL
    if (Get-Command psql -ErrorAction SilentlyContinue) {
        $pgVersion = psql --version
        $installations.PostgreSQL = $pgVersion
        Write-LogInfo "PostgreSQL found: $pgVersion"
    } else {
        Write-LogInfo "PostgreSQL not found"
    }
    
    # Check Docker
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        $dockerVersion = docker --version
        $installations.Docker = $dockerVersion
        Write-LogInfo "Docker found: $dockerVersion"
    } else {
        Write-LogInfo "Docker not found"
    }
    
    return $installations
}

# Check command existence
function Test-CommandExists {
    param([string]$Command)
    
    return (Get-Command $Command -ErrorAction SilentlyContinue) -ne $null
}

# Get system information
function Get-SystemInfo {
    Write-Host "=== System Information ===" -ForegroundColor Blue
    Write-Host "Operating System: $(Get-OperatingSystem)"
    Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
    Write-Host "Current User: $env:USERNAME"
    Write-Host "Working Directory: $(Get-Location)"
    Write-Host "Computer Name: $env:COMPUTERNAME"
    Write-Host ""
}

# Validate system compatibility
function Test-SystemCompatibility {
    $os = Get-OperatingSystem
    if ($os -eq "unknown") {
        Write-LogError "Unsupported operating system"
        return $false
    }
    
    if (-not (Test-SystemRequirements)) {
        Write-LogError "System requirements not met"
        return $false
    }
    
    # Check existing installations
    $installations = Test-ExistingInstallations
    return $true
}

