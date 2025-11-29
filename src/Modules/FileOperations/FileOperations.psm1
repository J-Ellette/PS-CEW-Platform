<#
.SYNOPSIS
  Safe file operation functions (copy/move/delete) that honor ACLs and SupportsShouldProcess.
#>

function Move-SafeItem {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string] $SourcePath,

        [Parameter(Mandatory=$true)]
        [string] $DestinationPath,

        [switch] $Overwrite
    )

    <#
    .SYNOPSIS
      Moves a file or folder with pre-validation and ACL checks.

    .PARAMETER SourcePath
      Source path to move.

    .PARAMETER DestinationPath
      Destination path.

    .PARAMETER Overwrite
      If set, will overwrite existing destination (subject to ACL and Confirm prompts).
    #>

    try {
        Import-Module (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\Security\SecurityHelpers.psm1') -ErrorAction SilentlyContinue

        $src = Test-SecureInput -InputPath $SourcePath
        $dst = Test-SecureInput -InputPath $DestinationPath

        if (-not (Test-Path -LiteralPath $src -PathType Any)) {
            throw "Source does not exist: $src"
        }

        if ($PSCmdlet.ShouldProcess("Move '$src' -> '$dst'")) {
            if (Test-Path -LiteralPath $dst -PathType Any) {
                if ($Overwrite) {
                    Remove-Item -LiteralPath $dst -Recurse -Force -ErrorAction Stop
                } else {
                    throw "Destination exists. Use -Overwrite to overwrite."
                }
            }

            Move-Item -LiteralPath $src -Destination $dst -ErrorAction Stop
            Write-Verbose "Moved $src to $dst"
        }
    } catch {
        Write-Error $_
        return $false
    }

    return $true
}

Export-ModuleMember -Function * -Alias *
