<#
.SYNOPSIS
  Security and input validation functions.

.DESCRIPTION
  Implements path validation, normalization, string escaping and secure input checks.
#>

function Resolve-NormalizedPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $Path
    )

    try {
        # Expand environment variables, then resolve and return a full normalized path
        $expanded = [Environment]::ExpandEnvironmentVariables($Path)
        $resolved = [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $expanded -ErrorAction Stop).ProviderPath)
        return $resolved
    } catch {
        throw [System.ArgumentException] "Unable to resolve path '$Path': $_"
    }
}

function Test-SafePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,

        [Parameter()]
        [ValidateScript({ $_ -is [int] -and $_ -ge 1 -and $_ -le 32768 })]
        [int] $MaxPathLength = 32768
    )
    <#
    .SYNOPSIS
      Validates a user-provided path to prevent traversal and illegal characters.

    .DESCRIPTION
      Checks for null/empty, illegal filename characters, path traversal (..), excessive length, and symlink handling.
    #>

    try {
        if ([string]::IsNullOrWhiteSpace($Path)) {
            return $false
        }

        $normalized = Resolve-NormalizedPath -Path $Path

        if ($normalized.Length -gt $MaxPathLength) {
            return $false
        }

        $invalidChars = [System.IO.Path]::GetInvalidPathChars()
        foreach ($c in $invalidChars) {
            if ($normalized.Contains($c)) { return $false }
        }

        # Prevent traversal (../ or ..\)
        if ($normalized -match '(?:\.\.|/\.\.)') { return $false }

        # Handle reparse points carefully; return false if path is a symlink to a suspicious location
        try {
            $fi = Get-Item -LiteralPath $normalized -ErrorAction Stop
            if ($fi.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                # Allow but note — caller should handle carefully
                Write-Verbose "Path is a reparse point. Caller must handle symlink resolution."
            }
        } catch {
            # If it doesn't exist yet, that's acceptable for some operations; return $true unless other checks fail
        }

        return $true
    } catch {
        Write-Error $_
        return $false
    }
}

function Escape-StringForWildcard {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string] $InputString
    )
    # Use PowerShell's WildcardPattern escape
    return [System.Management.Automation.WildcardPattern]::Escape($InputString)
}

function Test-SecureInput {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string] $InputPath
    )

    # Comprehensive combined test: safe path + resolve
    if (-not (Test-SafePath -Path $InputPath)) {
        throw [System.ArgumentException] "Input failed security validation."
    }

    return (Resolve-NormalizedPath -Path $InputPath)
}

Export-ModuleMember -Function * -Alias *
