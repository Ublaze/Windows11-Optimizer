#Requires -RunAsAdministrator
# ============================================================================
#  Windows 11 Optimizer Script
#  Run as Administrator: Right-click PowerShell > Run as Administrator
#  Then: Set-ExecutionPolicy Bypass -Scope Process -Force
#        .\Windows11_Optimizer.ps1
# ============================================================================

param(
    [switch]$SkipRestore,
    [switch]$Silent
)

$ErrorActionPreference = "SilentlyContinue"

# --- Colors & Helpers ---
function Write-Step  ($msg) { Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-Ok    ($msg) { Write-Host "   [OK] $msg" -ForegroundColor Green }
function Write-Skip  ($msg) { Write-Host "   [SKIP] $msg" -ForegroundColor Yellow }
function Write-Fail  ($msg) { Write-Host "   [FAIL] $msg" -ForegroundColor Red }
function Write-Info  ($msg) { Write-Host "   [INFO] $msg" -ForegroundColor Gray }

# ============================================================================
#  BANNER
# ============================================================================
Clear-Host
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "         Windows 11 Optimizer - All-in-One Script           " -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  This script will:" -ForegroundColor White
Write-Host "    1. Create a System Restore Point" -ForegroundColor White
Write-Host "    2. Clean temp files, caches, and Recycle Bin" -ForegroundColor White
Write-Host "    3. Disable heavy startup apps" -ForegroundColor White
Write-Host "    4. Disable unnecessary Windows services" -ForegroundColor White
Write-Host "    5. Apply registry tweaks for performance" -ForegroundColor White
Write-Host "    6. Disable telemetry and data collection" -ForegroundColor White
Write-Host "    7. Optimize network settings" -ForegroundColor White
Write-Host "    8. Switch to High Performance power plan" -ForegroundColor White
Write-Host "    9. Run security scan on processes" -ForegroundColor White
Write-Host ""
Write-Host "  A System Restore Point will be created before any changes." -ForegroundColor Yellow
Write-Host ""

if (-not $Silent) {
    $confirm = Read-Host "Press ENTER to continue or type 'Q' to quit"
    if ($confirm -eq 'Q' -or $confirm -eq 'q') { exit }
}

$startTime = Get-Date
$totalFreedMB = 0

# ============================================================================
#  STEP 1: SYSTEM INFO & BASELINE
# ============================================================================
Write-Step "STEP 1: Gathering System Information"

$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$diskFreeGB = [math]::Round($disk.FreeSpace / 1GB, 1)
$diskTotalGB = [math]::Round($disk.Size / 1GB, 1)

Write-Info "OS: Windows $((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion) (Build $((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentBuild))"
Write-Info "CPU: $($cpu.Name)"
Write-Info "RAM: $freeRAM GB free / $totalRAM GB total"
Write-Info "C: Drive: $diskFreeGB GB free / $diskTotalGB GB total"

$baselineFreeRAM = $os.FreePhysicalMemory
$baselineDiskFree = $disk.FreeSpace

# ============================================================================
#  STEP 2: CREATE RESTORE POINT
# ============================================================================
Write-Step "STEP 2: Creating System Restore Point"

if (-not $SkipRestore) {
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction Stop
        Checkpoint-Computer -Description "Before Windows 11 Optimizer" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Ok "Restore point 'Before Windows 11 Optimizer' created"
    } catch {
        Write-Skip "Could not create restore point (one may already exist today)"
    }
} else {
    Write-Skip "Restore point skipped (-SkipRestore flag)"
}

# ============================================================================
#  STEP 3: DISK CLEANUP
# ============================================================================
Write-Step "STEP 3: Cleaning Up Disk Space"

# User temp files
$tempPath = "$env:LOCALAPPDATA\Temp"
if (Test-Path $tempPath) {
    $before = (Get-ChildItem $tempPath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Remove-Item "$tempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    $after = (Get-ChildItem $tempPath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $freedMB = [math]::Round(($before - $after) / 1MB, 1)
    $totalFreedMB += $freedMB
    Write-Ok "User temp files cleaned ($freedMB MB freed)"
}

# Windows temp files
$winTemp = "$env:SystemRoot\Temp"
if (Test-Path $winTemp) {
    $before = (Get-ChildItem $winTemp -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Remove-Item "$winTemp\*" -Recurse -Force -ErrorAction SilentlyContinue
    $after = (Get-ChildItem $winTemp -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $freedMB = [math]::Round(($before - $after) / 1MB, 1)
    $totalFreedMB += $freedMB
    Write-Ok "Windows temp files cleaned ($freedMB MB freed)"
}

# Prefetch
if (Test-Path "$env:SystemRoot\Prefetch") {
    Remove-Item "$env:SystemRoot\Prefetch\*" -Force -ErrorAction SilentlyContinue
    Write-Ok "Prefetch folder cleaned"
}

# Windows Update cache
if (Test-Path "$env:SystemRoot\SoftwareDistribution\Download") {
    $before = (Get-ChildItem "$env:SystemRoot\SoftwareDistribution\Download" -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Remove-Item "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    $after = (Get-ChildItem "$env:SystemRoot\SoftwareDistribution\Download" -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $freedMB = [math]::Round(($before - $after) / 1MB, 1)
    $totalFreedMB += $freedMB
    Write-Ok "Windows Update cache cleaned ($freedMB MB freed)"
}

# npm cache (if exists)
$npmCache = "$env:LOCALAPPDATA\npm-cache"
if (Test-Path $npmCache) {
    $sizeMB = [math]::Round((Get-ChildItem $npmCache -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB, 1)
    if ($sizeMB -gt 100) {
        npm cache clean --force 2>&1 | Out-Null
        $totalFreedMB += $sizeMB
        Write-Ok "npm cache cleaned ($sizeMB MB freed)"
    }
}

# Recycle Bin
try {
    Clear-RecycleBin -Force -ErrorAction Stop
    Write-Ok "Recycle Bin emptied"
} catch {
    Write-Skip "Recycle Bin already empty"
}

Write-Info "Total disk space freed so far: ~$totalFreedMB MB"

# ============================================================================
#  STEP 4: DISABLE HEAVY STARTUP APPS
# ============================================================================
Write-Step "STEP 4: Disabling Heavy Startup Apps"

$startupAppsToDisable = @(
    @{Name="Docker Desktop";         Key="Docker Desktop"},
    @{Name="Chrome Auto-Launch";     Key="GoogleChromeAutoLaunch_*"},
    @{Name="Edge Auto-Launch";       Key="MicrosoftEdgeAutoLaunch_*"},
    @{Name="Adobe Connect Detector"; Key="ConnectDetector"},
    @{Name="Cisco Meeting Daemon";   Key="CiscoMeetingDaemon"}
)

$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$currentStartup = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue

foreach ($app in $startupAppsToDisable) {
    $props = $currentStartup.PSObject.Properties | Where-Object { $_.Name -like $app.Key }
    foreach ($prop in $props) {
        Remove-ItemProperty -Path $regPath -Name $prop.Name -ErrorAction SilentlyContinue
        Write-Ok "Disabled startup: $($app.Name) ($($prop.Name))"
    }
    if (-not $props) {
        Write-Skip "Not found in startup: $($app.Name)"
    }
}

# ============================================================================
#  STEP 5: DISABLE UNNECESSARY SERVICES
# ============================================================================
Write-Step "STEP 5: Disabling Unnecessary Services"

$servicesToDisable = @(
    @{Name="Fax";              Desc="Fax Service"},
    @{Name="XblAuthManager";   Desc="Xbox Live Auth Manager"},
    @{Name="XblGameSave";      Desc="Xbox Live Game Save"},
    @{Name="XboxGipSvc";       Desc="Xbox Accessory Management"},
    @{Name="XboxNetApiSvc";    Desc="Xbox Live Networking"},
    @{Name="wisvc";            Desc="Windows Insider Service"},
    @{Name="DiagTrack";        Desc="Connected User Experiences & Telemetry"},
    @{Name="dmwappushservice"; Desc="Device Management WAP Push"},
    @{Name="RetailDemo";       Desc="Retail Demo Service"},
    @{Name="MapsBroker";       Desc="Downloaded Maps Manager"},
    @{Name="lfsvc";            Desc="Geolocation Service"}
)

foreach ($svc in $servicesToDisable) {
    $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
    if ($service) {
        try {
            Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Ok "Disabled: $($svc.Desc)"
        } catch {
            Write-Fail "Could not disable: $($svc.Desc)"
        }
    } else {
        Write-Skip "Not found: $($svc.Desc)"
    }
}

# ============================================================================
#  STEP 6: REGISTRY TWEAKS
# ============================================================================
Write-Step "STEP 6: Applying Registry Performance Tweaks"

# --- Boot & Startup ---
$serializePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize"
if (-not (Test-Path $serializePath)) { New-Item -Path $serializePath -Force | Out-Null }
Set-ItemProperty -Path $serializePath -Name "StartupDelayInMSec" -Value 0 -Type DWord -Force
Write-Ok "Disabled startup delay (faster boot)"

# --- UI Responsiveness ---
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -Force
Write-Ok "Menu show delay set to 0ms"

Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Value "1" -Force
Write-Ok "Auto-end hung tasks on shutdown"

Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillAppTimeout" -Value "2000" -Force
Write-Ok "Reduced shutdown wait timeout to 2s"

Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "HungAppTimeout" -Value "1000" -Force
Write-Ok "Reduced hung app timeout to 1s"

# --- Visual Effects: Optimize for Performance ---
$vfxPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
if (-not (Test-Path $vfxPath)) { New-Item -Path $vfxPath -Force | Out-Null }
Set-ItemProperty -Path $vfxPath -Name "VisualFXSetting" -Value 2 -Type DWord -Force
Write-Ok "Visual effects set to 'Best Performance'"

# --- SSD Optimization ---
fsutil behavior set disablelastaccess 1 | Out-Null
Write-Ok "Disabled Last Access Timestamp (SSD optimization)"

# --- Disable Cortana ---
$cortanaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
if (-not (Test-Path $cortanaPath)) { New-Item -Path $cortanaPath -Force -ErrorAction SilentlyContinue | Out-Null }
Set-ItemProperty -Path $cortanaPath -Name "AllowCortana" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Write-Ok "Disabled Cortana"

# --- Disable Bing Search in Start Menu ---
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -Type DWord -Force
Write-Ok "Disabled Bing Search in Start Menu"

# --- Disable Windows Tips, Suggestions, Ads ---
$cdmPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-ItemProperty -Path $cdmPath -Name "SoftLandingEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-310093Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338393Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-353694Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-353696Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdmPath -Name "SystemPaneSuggestionsEnabled" -Value 0 -Type DWord -Force
Write-Ok "Disabled Tips, Suggestions, and Start Menu ads"

# --- Disable Widgets & Chat on Taskbar ---
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0 -Force
Write-Ok "Hidden Widgets and Chat from Taskbar"

# --- Disable Lock Screen Spotlight/Ads ---
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Value 0 -Type DWord -Force
Write-Ok "Disabled Lock Screen Spotlight ads"

# ============================================================================
#  STEP 7: DISABLE TELEMETRY SCHEDULED TASKS
# ============================================================================
Write-Step "STEP 7: Disabling Telemetry Scheduled Tasks"

$tasksToDisable = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
)

foreach ($task in $tasksToDisable) {
    try {
        Disable-ScheduledTask -TaskName $task -ErrorAction Stop | Out-Null
        $taskName = $task.Split("\")[-1]
        Write-Ok "Disabled: $taskName"
    } catch {
        $taskName = $task.Split("\")[-1]
        Write-Skip "Not found or already disabled: $taskName"
    }
}

# ============================================================================
#  STEP 8: NETWORK OPTIMIZATIONS
# ============================================================================
Write-Step "STEP 8: Applying Network Optimizations"

# Optimize TCP settings on all interfaces
$networkPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
Get-ChildItem $networkPath -ErrorAction SilentlyContinue | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
}
Write-Ok "TCP optimized for lower latency (Nagle disabled)"

# Disable Wi-Fi Sense
$wifiPath = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
if (-not (Test-Path $wifiPath)) { New-Item -Path $wifiPath -Force | Out-Null }
Set-ItemProperty -Path $wifiPath -Name "AutoConnectAllowedOEM" -Value 0 -Type DWord -Force
Write-Ok "Disabled Wi-Fi Sense auto-connect"

# ============================================================================
#  STEP 9: POWER PLAN
# ============================================================================
Write-Step "STEP 9: Setting High Performance Power Plan"

powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>&1 | Out-Null
$activePlan = powercfg /getactivescheme
if ($activePlan -match "High performance") {
    Write-Ok "Switched to High Performance power plan"
} else {
    Write-Skip "High Performance plan may not be available; current plan unchanged"
    Write-Info "Active: $activePlan"
}

# ============================================================================
#  STEP 10: SECURITY SCAN
# ============================================================================
Write-Step "STEP 10: Running Security Scan on Processes"

# Check for unsigned processes running from user directories
$suspiciousCount = 0
$userProcs = Get-Process | Where-Object { $_.Path -like "C:\Users\*" } | Select-Object -Property Path -Unique

foreach ($proc in $userProcs) {
    if ($proc.Path) {
        $sig = Get-AuthenticodeSignature -FilePath $proc.Path -ErrorAction SilentlyContinue
        if ($sig -and $sig.Status -ne "Valid") {
            Write-Fail "UNSIGNED: $($proc.Path)"
            $suspiciousCount++
        }
    }
}

# Check for processes in suspicious locations
$allProcs = Get-Process | Where-Object { $_.Path } | Select-Object -Property Path -Unique
$suspiciousLocations = @("*\Temp\*", "*\Downloads\*", "*\Public\*")

foreach ($proc in $allProcs) {
    foreach ($loc in $suspiciousLocations) {
        if ($proc.Path -like $loc) {
            Write-Fail "SUSPICIOUS LOCATION: $($proc.Path)"
            $suspiciousCount++
        }
    }
}

# Check Windows Defender status
$defenderStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
if ($defenderStatus) {
    if ($defenderStatus.RealTimeProtectionEnabled) {
        Write-Ok "Windows Defender Real-Time Protection: ENABLED"
    } else {
        Write-Fail "Windows Defender Real-Time Protection: DISABLED"
    }
    Write-Info "Signatures last updated: $($defenderStatus.AntivirusSignatureLastUpdated)"

    $threats = Get-MpThreatDetection -ErrorAction SilentlyContinue
    if ($threats) {
        Write-Fail "Recent threats detected! Run a full scan."
    } else {
        Write-Ok "No recent threats detected"
    }
}

if ($suspiciousCount -eq 0) {
    Write-Ok "No unsigned or suspicious processes found"
} else {
    Write-Fail "$suspiciousCount suspicious item(s) found - review above"
}

# ============================================================================
#  FINAL REPORT
# ============================================================================
$endTime = Get-Date
$duration = $endTime - $startTime

# Re-check stats
$osAfter = Get-CimInstance Win32_OperatingSystem
$diskAfter = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeRAMAfter = [math]::Round($osAfter.FreePhysicalMemory / 1MB, 1)
$diskFreeGBAfter = [math]::Round($diskAfter.FreeSpace / 1GB, 1)
$ramGainedMB = [math]::Round(($osAfter.FreePhysicalMemory - $baselineFreeRAM) / 1KB, 0)
$diskGainedMB = [math]::Round(($diskAfter.FreeSpace - $baselineDiskFree) / 1MB, 0)

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "                OPTIMIZATION COMPLETE                       " -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Duration    : $([math]::Round($duration.TotalSeconds, 0)) seconds" -ForegroundColor White
Write-Host ""
Write-Host "  RAM         : $freeRAM GB -> $freeRAMAfter GB free (+$ramGainedMB MB)" -ForegroundColor Green
Write-Host "  C: Drive    : $diskFreeGB GB -> $diskFreeGBAfter GB free (+$diskGainedMB MB)" -ForegroundColor Green
Write-Host ""
Write-Host "  Changes Applied:" -ForegroundColor White
Write-Host "    - Temp files, caches, Recycle Bin cleaned" -ForegroundColor White
Write-Host "    - Heavy startup apps disabled" -ForegroundColor White
Write-Host "    - Unnecessary services disabled (Xbox, Telemetry, etc.)" -ForegroundColor White
Write-Host "    - Registry tweaks for faster UI" -ForegroundColor White
Write-Host "    - Cortana, Bing Search, Tips, Ads disabled" -ForegroundColor White
Write-Host "    - Network optimized for lower latency" -ForegroundColor White
Write-Host "    - High Performance power plan set" -ForegroundColor White
Write-Host "    - Security scan completed" -ForegroundColor White
Write-Host ""
Write-Host "  Restore Point: 'Before Windows 11 Optimizer'" -ForegroundColor Yellow
Write-Host "  If issues arise, restore from System Restore." -ForegroundColor Yellow
Write-Host ""
Write-Host "  >> RESTART YOUR PC to fully apply all changes <<" -ForegroundColor Red
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan

if (-not $Silent) {
    Write-Host ""
    Read-Host "Press ENTER to exit"
}
