# Script to Configure FSLogix Profile Containers

# Define variables
$registryPath = "HKLM:\SOFTWARE\FSLogix\Profiles"
$storageAccount = "<storage-account-name>.file.core.windows.net"
$shareName = "<share-name>"
$vhdLocation = "\\$storageAccount\$shareName"

# Ensure the script is run with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Please run this script as an administrator."
    exit
}

# Verify FSLogix installation
Write-Host "Verifying FSLogix installation..." -ForegroundColor Green
if (-not (Test-Path "C:\Program Files\FSLogix\Apps")) {
    Write-Error "FSLogix is not installed. Please download and install the latest version."
    exit
}

# Set registry keys for FSLogix profile container
Write-Host "Configuring FSLogix registry keys..." -ForegroundColor Green
New-Item -Path $registryPath -Force | Out-Null

# Registry key configuration
$registrySettings = @(
    @{ Name = "Enabled"; DataType = "DWORD"; Value = 1; Description = "Enable FSLogix Profiles" },
    @{ Name = "DeleteLocalProfileWhenVHDShouldApply"; DataType = "DWORD"; Value = 1; Description = "Delete local profiles to avoid data loss" },
    @{ Name = "FlipFlopProfileDirectoryName"; DataType = "DWORD"; Value = 1; Description = "Simplifies container directory browsing" },
    @{ Name = "LockedRetryCount"; DataType = "DWORD"; Value = 3; Description = "Retry count for locked profiles" },
    @{ Name = "LockedRetryInterval"; DataType = "DWORD"; Value = 15; Description = "Retry interval in seconds" },
    @{ Name = "ProfileType"; DataType = "DWORD"; Value = 0; Description = "Single connection for simplicity and performance" },
    @{ Name = "ReAttachIntervalSeconds"; DataType = "DWORD"; Value = 15; Description = "Interval for reattach attempts" },
    @{ Name = "ReAttachRetryCount"; DataType = "DWORD"; Value = 3; Description = "Retry count for reattachment" },
    @{ Name = "SizeInMBs"; DataType = "DWORD"; Value = 30000; Description = "Default container size" },
    @{ Name = "VHDLocations"; DataType = "MULTI_SZ"; Value = $vhdLocation; Description = "VHD storage location" },
    @{ Name = "VolumeType"; DataType = "REG_SZ"; Value = "VHDX"; Description = "Preferred over VHD for size and reliability" }
)

foreach ($setting in $registrySettings) {
    New-ItemProperty -Path $registryPath -Name $setting.Name -Value $setting.Value -PropertyType $setting.DataType -Force | Out-Null
    Write-Host "Configured $($setting.Name): $($setting.Value)" -ForegroundColor Yellow
}

# Verify configuration
Write-Host "Verifying FSLogix configuration..." -ForegroundColor Green
cd "C:\Program Files\FSLogix\Apps"
$output = & frx list-redirects
Write-Output $output

# Check VHD location
Write-Host "Checking VHD location..." -ForegroundColor Green
if (-not (Test-Path $vhdLocation)) {
    Write-Error "The specified VHD location does not exist or is inaccessible: $vhdLocation"
    exit
}

Write-Host "Configuration complete. Please verify the FSLogix profile container in the SMB file share." -ForegroundColor Cyan
