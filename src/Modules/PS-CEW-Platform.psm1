<#
.SYNOPSIS
    PS-CEW-Platform module aggregator.

.DESCRIPTION
    Loads submodule files (Security, Core, FileOperations) from the module folder.
#>

# Use $PSScriptRoot which is guaranteed inside modules/scripts on PowerShell 3+
$moduleRoot = $PSScriptRoot
if (-not $moduleRoot) {
    # Fallback (should rarely be necessary)
    $moduleRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
}

# Prepend module root to PSModulePath so nested Import-Module calls can find helpers if needed.
# Use an interpolated string to avoid concatenation edge cases.
$env:PSModulePath = "$moduleRoot;$($env:PSModulePath)"

# List submodules relative to the module root (use backslashes to match the filesystem)
$submodules = @(
    'Security\SecurityHelpers.psm1',
    'Core\CoreHelpers.psm1',
    'FileOperations\FileOperations.psm1'
)

foreach ($sub in $submodules) {
    $file = Join-Path -Path $moduleRoot -ChildPath $sub
    if (Test-Path -LiteralPath $file) {
        try {
            # Import by path. -DisableNameChecking reduces noisy warnings for function name overlaps during development.
            Import-Module -Name $file -Force -DisableNameChecking -ErrorAction Stop
        } catch {
            Write-Error "Failed to import submodule '$sub' (`$file = $file`): $_"
        }
    } else {
        Write-Verbose "Submodule file not found: $file"
    }
}

# Export everything the submodules exported
Export-ModuleMember -Function * -Alias *
