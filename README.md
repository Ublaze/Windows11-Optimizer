<p align="center">
  <img src="assets/banner.svg" alt="Windows 11 Optimizer" width="100%">
</p>

<p align="center">
  <strong>Debloat, speed up, and lock down Windows 11 — in one script.</strong>
</p>

<p align="center">
  <a href="#quick-start"><img src="https://img.shields.io/badge/Windows-10%2F11-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Windows"></a>
  <a href="https://docs.microsoft.com/powershell/"><img src="https://img.shields.io/badge/PowerShell-5.1+-5391FE?style=flat-square&logo=powershell&logoColor=white" alt="PowerShell"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License"></a>
  <a href="https://github.com/Ublaze/Windows11-Optimizer/stargazers"><img src="https://img.shields.io/github/stars/Ublaze/Windows11-Optimizer?style=flat-square" alt="Stars"></a>
</p>

---

<details>
<summary><strong>Table of Contents</strong></summary>

- [Why This Over Alternatives?](#why-this-over-alternatives)
- [What It Does](#what-it-does)
- [Quick Start](#quick-start)
- [One-Liner (Download & Run)](#one-liner-download--run)
- [Options](#options)
- [What Gets Disabled](#what-gets-disabled)
- [Safety](#safety)
- [Before & After](#before--after)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)

</details>

One script handles everything you'd normally spend an afternoon tweaking. No registry editors, no hunting through settings, no third-party bloatware removers.

## Why This Over Alternatives?

| Feature | Windows 11 Optimizer | Chris Titus WinUtil | Sophia Script | O&O ShutUp10 |
|---------|:---:|:---:|:---:|:---:|
| Single script, no install | Yes | - | - | - |
| Auto restore point | Yes | - | Yes | - |
| Disk cleanup | Yes | - | - | - |
| Startup optimization | Yes | Yes | - | - |
| Service debloating | Yes | Yes | Yes | - |
| Privacy/telemetry | Yes | Yes | Yes | Yes |
| Network optimization | Yes | - | - | - |
| Security scan | Yes | - | - | - |
| Silent mode | Yes | - | Partial | - |
| Before/after comparison | Yes | - | - | - |
| Open source | MIT | MIT | MIT | - |

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

## Contributing

Want to add a new optimization or fix a bug? Check out [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE)

---

<div align="center">

If this script saved you time, consider giving it a :star: — it helps others find it!

</div>
