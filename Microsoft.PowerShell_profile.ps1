Function prompt {
    $dt = (Get-Date -Format "MM-dd-yy HH:mm:ss")
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $location = $executionContext.SessionState.Path.CurrentLocation.path
    $len = 33

    if ($location.length -gt $len) {
        $dsc = [system.io.path]::DirectorySeparatorChar
        $split = $location -split "\$($dsc)" | Where-Object { $_ -match "\S+" }
        $here = "{0}$dsc{1}...$dsc{2}" -f $split[0], $split[1], $split[-1]
    }
    else {
        $here = $location
    }

    $prefix = $(if (Test-Path variable:/PSDebugContext) {'[DBG]:PS'}
        elseif ($principal.IsInRole($adminRole)) {'[ADMIN]:PS'}
      else {'PS '}
      )
    $body = "$($PSVersionTable.PSversion.major).$($PSVersionTable.PSversion.minor) $($here)$('>' * ($nestedPromptLevel + 1))"

    write-host "[$dt] " -ForegroundColor yellow -NoNewline
    $prefix+$body
}


function Update-Profile {
  # Update function borrowed from https://github.com/PantiesIsStoopid/PowerShell 
    try {
      $url = "https://raw.githubusercontent.com/Houndtech/TMShares/refs/heads/main/Microsoft.PowerShell_profile.ps1"
      $oldhash = Get-FileHash $PROFILE
      Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
      $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
      if ($newhash.Hash -ne $oldhash.Hash) {
        Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
        Write-Host "Profile has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
      }
      else {
        Write-Host "Profile is up to date." -ForegroundColor Green
      }
    }
    catch {
      Write-Error "Unable to check for `$profile updates: $_"
    }
    finally {
      Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
    }
  }
