# Windows 11 Optimizer

A safe, all-in-one PowerShell script to optimize Windows 11 for better performance, reduced bloat, and improved privacy.

## What It Does

| Step | Action | Details |
|------|--------|---------|
| 1 | **System Info** | Gathers baseline stats (RAM, disk, OS version) |
| 2 | **Restore Point** | Creates a System Restore point before any changes |
| 3 | **Disk Cleanup** | Cleans temp files, caches, Windows Update downloads, Recycle Bin |
| 4 | **Startup Apps** | Disables heavy auto-start apps (Docker, Chrome/Edge auto-launch, etc.) |
| 5 | **Services** | Disables unused services (Xbox, Telemetry, Fax, Maps, Insider) |
| 6 | **Registry Tweaks** | Faster boot, snappier menus, disables Cortana/Bing/ads/tips |
| 7 | **Telemetry Tasks** | Disables data collection scheduled tasks |
| 8 | **Network** | TCP optimization for lower latency, disables Wi-Fi Sense |
| 9 | **Power Plan** | Switches to High Performance power plan |
| 10 | **Security Scan** | Checks for unsigned/suspicious processes, verifies Defender status |

## Quick Start

1. **Right-click PowerShell** and select **Run as Administrator**
2. Run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Windows11_Optimizer.ps1
```

3. Follow the on-screen prompts
4. **Restart** your PC when done

## One-Liner (Download & Run)

```powershell
irm "https://raw.githubusercontent.com/Ublaze/Windows11-Optimizer/main/Windows11_Optimizer.ps1" -OutFile "$env:TEMP\Win11Opt.ps1"; Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File $env:TEMP\Win11Opt.ps1"
```

## Options

| Flag | Description |
|------|-------------|
| `-SkipRestore` | Skip creating a System Restore point |
| `-Silent` | Run without interactive prompts |

```powershell
# Example: run silently without restore point
.\Windows11_Optimizer.ps1 -Silent -SkipRestore
```

## What Gets Disabled

### Services
- Xbox Live Auth Manager, Game Save, Accessory Management, Networking
- Connected User Experiences and Telemetry
- Windows Insider Service
- Device Management WAP Push
- Fax, Downloaded Maps Manager, Geolocation Service, Retail Demo

### Startup Apps
- Docker Desktop, Chrome/Edge auto-launch, Adobe Connect Detector, Cisco Meeting Daemon

### Registry Changes
- Startup delay removed
- Menu/hover delays reduced to 0ms
- Shutdown timeouts reduced
- Visual effects set to performance mode
- Cortana, Bing Search in Start Menu disabled
- Windows tips, suggestions, lock screen ads disabled
- Widgets and Chat hidden from taskbar

### Scheduled Tasks
- Microsoft Compatibility Appraiser
- Program Data Updater
- CEIP Consolidator and USB CEIP
- Disk Diagnostic Data Collector

## Safety

- A **System Restore point** is created before any changes
- All changes can be reversed through System Restore
- Only well-known safe optimizations are applied
- No critical Windows services are touched
- Digital signature verification is performed on running processes

## Before & After

The script displays a comparison at the end:

```
  RAM         : 1.2 GB -> 2.1 GB free (+900 MB)
  C: Drive    : 26.0 GB -> 28.5 GB free (+2500 MB)
```

## Requirements

- Windows 11 (also works on Windows 10)
- PowerShell 5.1+
- Administrator privileges

## License

MIT License - see [LICENSE](LICENSE)
