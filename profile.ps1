oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\di4am0nd.omp.json" | Invoke-Expression
Import-Module z
# Import PSReadLine Module
Import-Module PSReadLine

# Enable suggestion predictions from history
Set-PSReadLineOption -PredictionSource History

# Set the prediction view style to ListView
Set-PSReadLineOption -PredictionViewStyle ListView

# Customize list view colors (optional)
Set-PSReadLineOption -Colors @{
    ListPrediction = "`e[93m" # Yellow text for the list
}

Import-Module Terminal-Icons

clear
# PowerShell Functions

# Enhanced ls with colored output
function ls {
  param (
      [string]$Path = "."
  )
  $items = Get-ChildItem -Path $Path

  $dirColor = "Yellow"
  $exeColor = "Green"
  $linkColor = "Cyan"
  $fileColor = "White"

  foreach ($item in $items) {
      $color = $fileColor
      if ($item.PSIsContainer) {
          $color = $dirColor
      } elseif ($item.Extension -eq ".exe" -or $item.Extension -eq ".bat" -or $item.Extension -eq ".cmd") {
          $color = $exeColor
      } elseif ($item.Attributes -match "ReparsePoint") {
          $color = $linkColor
      }
      Write-Host $item.Name -ForegroundColor $color
  }
}

# Enhanced cd to support multiple dots directly
function cd {
  param (
      [string]$Path = ""
  )

  if ($Path -match "^\.+$") {
      $dotCount = ($Path -split "\\.").Length - 1
      for ($i = 1; $i -le $dotCount; $i++) {
          Set-Location ..
      }
  } else {
      Set-Location $Path
  }
}

# Support for directly using multiple dots without cd
function global:.. { Set-Location .. }
function global:... { cd ... }
function global:.... { cd .... }
function global:..... { cd ..... }
function global:...... { cd ...... }

# Function for opening files or directories like macOS 'open'
function open {
  param (
      [string[]]$Paths
  )
  foreach ($Path in $Paths) {
      $ResolvedPath = Resolve-Path -Path $Path
      Start-Process -FilePath $ResolvedPath
  }
}

# Git Aliases
function gst { git status }
function gl { git pull }
function glo { git log --oneline --graph --decorate }
function gup { git push }
function gaa { git add . }
function gcm { param([string]$Message) git commit -m $Message }
function gco { param([string]$Branch) git checkout $Branch }
function gbr { git branch }
function gdf { git diff }
function gcp { param([string]$Commit) git cherry-pick $Commit }

# Additional Shell Command Functions
function rm {
    param (
        [string[]]$Paths,
        [switch]$Force,
        [switch]$Recurse
    )
    foreach ($Path in $Paths) {
        if (Test-Path $Path) {
            try {
                Remove-Item -Path $Path -Force:$Force.IsPresent -Recurse:$Recurse.IsPresent
            } catch {
                Write-Host "rm: Failed to remove ${Path}: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "rm: ${Path}: No such file or directory" -ForegroundColor Red
        }
    }
}


function mkdir {
  param (
      [string]$Name
  )
  New-Item -Path $Name -ItemType Directory
}

function mv {
  param (
      [string]$Source,
      [string]$Destination
  )
  Move-Item -Path $Source -Destination $Destination
}

function cp {
  param (
      [string]$Source,
      [string]$Destination
  )
  Copy-Item -Path $Source -Destination $Destination
}

function pwd {
  Get-Location
}

function touch {
  param (
      [string[]]$Files
  )
  foreach ($File in $Files) {
      if (!(Test-Path $File)) {
          New-Item -Path $File -ItemType File | Out-Null
      }
  }
}

function l {
  param (
      [string]$Path = "."
  )
  ls $Path
}

function ws {
    param ([string[]]$Args)
    & webstorm64.exe @Args
}
