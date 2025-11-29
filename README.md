# PS-CEW-Platform

A PowerShell 7 reimplementation of CEW-Platform — a command-centric file manager with rich GUI integration, advanced file operations, and extensive PowerShell scripting capabilities.

Goals
- Convert CEW-Platform into a 100% PowerShell 7 project
- Maintain strict security practices (input validation, path normalization, secret handling, AES-256 support)
- Provide a modular structure with small, testable modules under src/Modules
- Offer a WPF-based GUI on Windows and a fallback CLI/TUI or Avalonia-based GUI path for cross-platform

Repo layout
- src/
  - Modules/ (Core, FileOperations, Navigation, Search, Integration, Preview, Security, System)
  - Scripts/ (Start-PS-CEWPlatform.ps1)
- UI/ (WPF XAML and resources)
- Resources/ (icons, themes)
- tests/ (Pester tests)
- .github/workflows/ (CI)

Security & Coding Standards
- PascalCase function names, approved verbs
- [CmdletBinding(SupportsShouldProcess=$true)] where destructive
- Parameter validation, ValidateScript for complex checks
- Use SecureString for password parameters
- No Invoke-Expression on user input
- Path validation via Test-SafePath and Resolve-NormalizedPath
- Escape strings using [System.Management.Automation.WildcardPattern]::Escape()

Getting started (local)
1. Install PowerShell 7.x
2. Clone the repo
3. Import the module: Import-Module ./src/Modules/PS-CEW-Platform.psm1
4. Start the app: .\src\Scripts\Start-PS-CEWPlatform.ps1 -InitialPath "C:\"

Development
- Unit tests use Pester (see .github/workflows/powershell.yml)
- Lint with PSScriptAnalyzer

License
- Add your preferred license file (e.g., MIT) in the repository root.
