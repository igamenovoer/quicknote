#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Installs and configures Pixi on Windows with custom paths and environments.
.DESCRIPTION
    This script provides a guided installation of Pixi. It performs the following steps:
    1. Ensures it is run with Administrator privileges.
    2. Prompts the user for a custom installation directory for Pixi.
    3. Installs Pixi to the specified directory.
    4. Asks the user whether to configure Pixi for per-user or shared global environments and sets the PIXI_HOME environment variable accordingly.
    5. Adds the Pixi executable to the system PATH.
    6. Asks the user if they want to create a 'common' global environment with a predefined set of packages (pipx, scipy, etc.).
    7. If the 'common' environment is created, its scripts directory is also added to the system PATH.
.NOTES
    - This script must be run as an Administrator.
    - A terminal restart is required after the script completes for all environment variable changes to take effect.
#>

# --- Initial Setup and Helper Functions ---

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-Header($message) {
    Write-Host "--------------------------------------------------" -ForegroundColor Green
    Write-Host $message -ForegroundColor Green
    Write-Host "--------------------------------------------------" -ForegroundColor Green
}

function Add-To-System-Path($pathToAdd) {
    try {
        $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
        if (-not ($currentPath -split ';').Contains($pathToAdd)) {
            $newPath = "$currentPath;$pathToAdd"
            [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
            Write-Host "Successfully added '$pathToAdd' to the system PATH." -ForegroundColor Cyan
        } else {
            Write-Host "'$pathToAdd' is already in the system PATH." -ForegroundColor Yellow
        }
    } catch {
        Write-Error "Failed to add '$pathToAdd' to system PATH. Error: $_"
    }
}

function Set-System-Env-Var($name, $value) {
    try {
        [System.Environment]::SetEnvironmentVariable($name, $value, "Machine")
        Write-Host "Successfully set system environment variable '$name' to '$value'." -ForegroundColor Cyan
    } catch {
        Write-Error "Failed to set system environment variable '$name'. Error: $_"
    }
}


# --- Main Script Logic ---

if (-not (Test-Admin)) {
    Write-Error "This script must be run with Administrator privileges."
    Write-Host "Please re-run this script in a terminal with Administrator rights."
    exit 1
}

Clear-Host
Write-Header "Pixi Interactive Installer for Windows"

# 1. Get Pix
$defaultPixiPath = "D:\Program Files\pixi"
$pixiInstallPath = Read-Host -Prompt "Enter the installation path for Pixi (press Enter for default: $defaultPixiPath)"
if ([string]::IsNullOrWhiteSpace($pixiInstallPath)) {
    $pixiInstallPath = $defaultPixiPath
}

# Normalize the path
$pixiInstallPath = [System.IO.Path]::GetFullPath($pixiInstallPath)
$pixiBinDir = Join-Path -Path $pixiInstallPath -ChildPath "bin"

Write-Host "Pixi will be installed in: '$pixiInstallPath'"
New-Item -Path $pixiInstallPath -ItemType Directory -Force | Out-Null

# 2. Install Pixi
Write-Header "Step 1: Installing Pixi"
Write-Host "Setting temporary environment variables for installation..."
$env:PIXI_HOME = $pixiInstallPath
$env:PIXI_BIN_DIR = $pixiBinDir

Write-Host "Downloading and running the Pixi installer..."
try {
    Invoke-RestMethod https://pixi.sh/install.ps1 | Invoke-Expression
    Write-Host "Pixi installed successfully to '$pixiInstallPath'." -ForegroundColor Green
} catch {
    Write-Error "Pixi installation failed. Error: $_"
    exit 1
}

# Add Pixi executable to the system PATH
Add-To-System-Path -pathToAdd $pixiBinDir

# 3. Configure PIXI_HOME location (Shared vs. Per-User)
Write-Header "Step 2: Configure Global Environment Location"
$choice = Read-Host -Prompt "Where should global environments be stored? (S)hared in '$pixiInstallPath' or (P)er-user in home directory? [S/P]"
$sharedConfig = $false

if ($choice -match '^s') {
    Write-Host "Configuring for a SHARED environment. Setting PIXI_HOME system variable." -ForegroundColor Cyan
    Set-System-Env-Var -name "PIXI_HOME" -value $pixiInstallPath
    $sharedConfig = $true
    # Set for the current process as well
    $env:PIXI_HOME = $pixiInstallPath
} else {
    Write-Host "Configuring for PER-USER environments. Each user will manage their own global environments in their home directory." -ForegroundColor Cyan
    # Unset for the current process to ensure default behavior
    Remove-Item -Path "env:PIXI_HOME" -ErrorAction SilentlyContinue
}

# 4. Install 'common' global environment
Write-Header "Step 3: Create 'common' Global Environment"
$createCommonEnv = Read-Host -Prompt "Do you want to create a 'common' global environment with standard packages (pipx, scipy, etc.)? [Y/N]"

if ($createCommonEnv -match '^y') {
    $packages = "pipx", "scipy", "attrs", "click", "rich", "omegaconf", "ipykernel"
    Write-Host "Installing packages into the 'common' global environment. This may take a few minutes..."
    
    try {
        # Ensure the pixi command is available in the current session's PATH
        $env:Path += ";$pixiBinDir"
        pixi global install --environment common $packages
        Write-Host "Successfully created and populated the 'common' environment." -ForegroundColor Green

        # Add the common env bin directory to PATH
        $commonEnvBinPath = ""
        if ($sharedConfig) {
            $commonEnvBinPath = Join-Path -Path $pixiInstallPath -ChildPath "envs\common\bin"
        } else {
            $userHome = $env:USERPROFILE
            $commonEnvBinPath = Join-Path -Path "$userHome\.pixi" -ChildPath "envs\common\bin"
        }
        
        Write-Host "Adding 'common' environment scripts to system PATH: '$commonEnvBinPath'"
        Add-To-System-Path -pathToAdd $commonEnvBinPath

    } catch {
        Write-Error "Failed to install packages into the 'common' environment. Error: $_"
    }
} else {
    Write-Host "Skipping creation of 'common' environment."
}

Write-Header "Installation and Configuration Complete!"
Write-Host "IMPORTANT: You must RESTART your terminal (or VS Code) for all changes to take effect." -ForegroundColor Yellow
