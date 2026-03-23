# Contributing to Windows 11 Optimizer

Thanks for wanting to improve the script! Here's how.

## Getting Started

1. Fork and clone the repo
2. Open `Windows11_Optimizer.ps1` in your editor of choice
3. Make your changes

## What makes a good contribution?

- **New optimizations** — well-known, safe tweaks that improve performance or privacy
- **Bug fixes** — something isn't working on certain Windows builds
- **Documentation** — improved explanations, corrected instructions

## Before submitting a PR

- Test on a Windows 11 VM or machine (please don't submit untested changes)
- Create a System Restore point before testing
- Keep your changes focused — one optimization or fix per PR
- Describe what the change does and *why* it's safe

## What NOT to contribute

- Aggressive tweaks that could break Windows functionality
- Changes to critical system services (Windows Update, Defender, etc.)
- Anything that requires additional downloads or dependencies

## Reporting bugs

[Open an issue](../../issues/new/choose) with:
- Your Windows version and build number
- What step failed
- The error message (screenshot or text)
