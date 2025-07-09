# Awtrix PowerShell Integration 🖥️⚡

[![PowerShell](https://img.shields.io/badge/powershell-7+-blue.svg?style=flat-square&logo=powershell)](https://docs.microsoft.com/powershell/)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/dapf27/awtrixPS.svg?style=flat-square&cacheSeconds=60)](https://github.com/dapf27/awtrixPS/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/dapf27/awtrixPS.svg?style=flat-square&cacheSeconds=60)](https://github.com/dapf27/awtrixPS/network)
[![GitHub issues](https://img.shields.io/github/issues/dapf27/awtrixPS.svg?style=flat-square)](https://github.com/dapf27/awtrixPS/issues)
[![Last Commit](https://img.shields.io/github/last-commit/dapf27/awtrixPS.svg?style=flat-square)](https://github.com/dapf27/awtrixPS/commits/main)

## 📋 Overview

This repository provides a set of PowerShell scripts and supporting files to integrate and automate the [Awtrix Smart Clock (Ulanzi Smart Pixel clock)](https://blueforcer.github.io/awtrix3) with various data sources and notifications. The scripts allow you to display worktime progress, weather, garbage collection schedules, Icinga monitoring status, Microsoft Teams status, and more on your Awtrix clock.

## 🔧 Features

- **Worktime Tracking:** Calculate and display daily worktime progress, including overtime, weekends, and holidays.
- **Weather Display:** Show current weather and temperature using OpenWeatherMap.
- **Garbage Collection:** Display upcoming waste collection days with icons.
- **Icinga Monitoring:** Show critical/unacknowledged hosts and services from Icinga.
- **Teams Status:** Display your current Microsoft Teams presence and activity.
- **Power/Display Control:** Automatically control the Awtrix display based on system lock and power state.
- **Custom Logo:** Show your company logo on the Awtrix clock.
- **Easy Scheduling:** Windows Task Scheduler XML and VBS files for automation.

## 📁 Directory Structure

```
awtrixPS/
├── Apps/
│ ├── Set-AwtrixWorktimeApp.ps1
│ ├── Set-AwtrixWeatherApp.ps1
│ ├── Set-AwtrixGarbageApps.ps1
│ ├── Set-AwtrixIcingaApp.ps1
│ ├── Set-AwtrixFoerchlogoApp.ps1
│ └── Files/
│ │ └── startwork.txt
├── Files/
│ ├── ICONS/
│ │ ├── 8x8/
│ │ │ ├── garbage/
│ │ │ │ ├── tonne_bio.gif
│ │ │ │ ├── tonne_gelb.gif
│ │ │ │ ├── tonne_papier.gif
│ │ │ │ └── tonne_restmuell.gif
│ │ │ ├── teams/
│ │ │ │ ├── 1232.gif
│ │ │ │ ├── 11520.jpg
│ │ │ │ ├── 46936.gif
│ │ │ │ └── 56891.jpg
│ │ │ └── weather/
│ │ │ │ ├── 876.jpg
│ │ │ │ ├── 2154.jpg
│ │ │ │ ├── 12294.jpg
│ │ │ │ ├── 43263.gif
│ │ │ │ ├── 55417.gif
│ │ │ │ ├── 60934.gif
│ │ │ │ ├── 60937.gif
│ │ │ │ └── 63084.gif
│ │ │ ├── 1609.gif
│ │ │ └── 8544.gif
│ │ ├── 32x8/
│ │ │ └── foerch.gif
│ └── README.md
├── Functions/
│ ├── Get-AwtrixLocation.ps1
│ ├── Get-GermanHoliday.ps1
│ ├── Get-EasterSunday.ps1
│ ├── Get-WorkTime.ps1
│ ├── Set-AwtrixWorktimeFile.ps1
│ ├── Test-TodayHoliday.ps1
│ └── Test-Weekend.ps1
├── Notifications/
│ └── Set-AwtrixTeamsStatusNotification.ps1
├── Tasks/
│ ├── *.xml (Task Scheduler definitions)
│ └── *.vbs (Task launcher scripts)
├── Set-AwtrixDisplay.ps1
├── .gitignore
└── README.md
```

## ▶️ Setup & Usage

### 1. Clone the Repository

```sh
git clone https://github.com/dapf27/awtrixPS.git
cd awtrixPS
```

### 2. Configure Your Environment

- Edit the scripts in `Functions/` and `Apps/` to set your Awtrix clock IP addresses, API keys, and other settings.
- Place your Awtrix icons in the correct folders as described in [Files/README.md](Files/README.md).

### 3. Scheduling

- Use the provided `.xml` files in `Tasks/` to import scheduled tasks into Windows Task Scheduler.
- The `.vbs` files are used to launch PowerShell scripts in the background.

### 4. Worktime Tracking

- On first run each day, `Set-AwtrixWorktimeFile.ps1` will prompt you for your start time and save it to `Apps/Files/startwork.txt`.
- The worktime app will update the Awtrix clock every minute.

### 5. Customization

- Adjust break times, working hours, and other parameters in the scripts as needed.
- Add or modify icons on your Awtrix clock as described in [Files/README.md](Files/README.md).

### 6. Icons 🖼️

- All icons are structured in the directories under Files/ICONS/:
8x8 and 32x8 pixels for Awtrix-compatible sizes
  - Categories: garbage, weather, teams

## ⚙️ Requirements

- Windows with PowerShell 7+
- Awtrix Smart Clock
- Network access between your PC and Awtrix clock
- (Optional) OpenWeatherMap API key, Icinga API access, etc.

## 📝 License

This project is licensed under the [MIT License](LICENSE).

## 👤 Credits

- Scripts by dapf27
- [Awtrix3 by Blueforcer](https://github.com/Blueforcer/awtrix3)
- Icons and APIs as referenced in individual scripts

## 🤝 Contributing
Contributions, issues and ideas are welcome!
Please open an issue or create a pull request. Please follow PowerShell best practices and test before submitting changes.
