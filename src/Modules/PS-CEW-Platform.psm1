# Primary module aggregator for PS-CEW-Platform
# Import module subfolders

$moduleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Add module path so nested modules can be imported
$env:PSModulePath = $moduleRoot + ";" + $env:PSModulePath

# Import each submodule file (explicitly load security and core helpers first)
$submodules = @(
    'Security/SecurityHelpers.psm1',
    'Core/CoreHelpers.psm1',
    'FileOperations/FileOperations.psm1'
)

foreach ($sub in $submodules) {
    $file = Join-Path $moduleRoot $sub
    if (Test-Path $file) {
        try {
            Import-Module $file -Force -DisableNameChecking -ErrorAction Stop
        } catch {
            Write-Error "Failed to import submodule $sub: $_"
        }
    }
}

Export-ModuleMember -Function * -Alias *
