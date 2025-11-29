<#
.SYNOPSIS
  Core helper functions (examples).
#>

function Get-FolderSize {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string] $Path
    )

    <#
    .SYNOPSIS
      Returns the total size (bytes) of a folder recursively.

    .DESCRIPTION
      Validates path with Test-SafePath and computes sum size.
    #>

    try {
        Import-Module (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\Security\SecurityHelpers.psm1') -ErrorAction SilentlyContinue

        $normalized = Test-SecureInput -InputPath $Path

        $folder = Get-Item -LiteralPath $normalized -ErrorAction Stop
        if (-not $folder.PSIsContainer) {
            throw "Path is not a folder."
        }

        $total = 0
        Get-ChildItem -LiteralPath $normalized -Recurse -ErrorAction Stop -Force | ForEach-Object {
            if (-not $_.PSIsContainer) {
                $total += $_.Length
            }
        }
        return $total
    } catch {
        throw
    }
}

Export-ModuleMember -Function * -Alias *
