
# Install Powershell modules
Write-Host "Installing PowerShell modules" -ForegroundColor Yellow
Install-Module -Name PowerShellGet -RequiredVersion 3.0.14-beta -Force -AllowPrerelease -Scope AllUsers
Set-PSResourceRepository -Name PSGallery -Trusted

Install-PSResource PSReadLine -Reinstall
Install-PSResource Powershell-yaml -Reinstall
Install-PSResource posh-git -Reinstall
Install-PSResource PowerShellForGitHub -Reinstall
Install-PSResource ImportExcel -Reinstall
Install-PSResource Terminal-Icons -Reinstall


Write-Host 'File Explorer Settings' -ForegroundColor Yellow
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Value 0
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

Write-Host 'Install WSL Ubuntu' -ForegroundColor Yellow
$env:WSLENV = 'USERPROFILE/p:APPDATA/p'
[environment]::setenvironmentvariable('WSLENV', $env:WSLENV, 'USER')
wsl --update
$wsl_distributions = wsl --list
if ($wsl_distributions -notcontains "Ubuntu" -and $wsl_distributions -notcontains "Ubuntu (Default)") {
  wsl --install -d Ubuntu
}


Write-Host 'Install application from winget' -ForegroundColor Yellow
winget install -e --id Microsoft.WindowsTerminal
winget install -e --id 7zip.7zip
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Microsoft.PowerToys
winget install -e --id Microsoft.dotnet
winget install -e --id Python.Python.3
winget install -e --id Amazon.AWSCLI
winget install -e --id OpenJS.NodeJS 
winget install -e --id suse.RancherDesktop
winget install -e --id Mirantis.Lens


# Cleanup desktop icons
Get-ChildItem "$([Environment]::GetFolderPath('DesktopDirectory'))" | ? { $_.Name -eq 'Microsoft Edge.lnk' } | Remove-Item


function Install-UserFont {
  [CmdletBinding(ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $true,
      Position = 0,
      ValueFromPipelineByPropertyName = $true)]
    [Uri]$Uri,
    [Parameter(Mandatory = $true,
      Position = 1,
      ValueFromPipelineByPropertyName = $true)]
    [String]$FontName

  )

  $fontFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)
  if ($fontFolder.Items() | Where-Object Name -eq $FontName) {
    Write-Warning "$FontName is already installed"
  }
  else {
    $fontFileName = [System.Uri]::UnescapeDataString(($Uri.Segments | Select-Object -Last 1 ))
    $fontFilePath = "$env:TEMP\$fontFileName"
    Invoke-WebRequest $Uri -OutFile $fontFilePath -UseBasicParsing

    $fontFolder.CopyHere($fontFilePath, 0x10)

    # Removed the downloaded file
    Remove-Item $fontFilePath -Force
  }
}

Write-Host 'Install Developer Fonts' -ForegroundColor Yellow
Install-UserFont -Uri 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Windows%20Compatible.ttf' `
  -FontName 'SauceCodePro NF Regular'
Install-UserFont -Uri 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/CascadiaCode/Regular/complete/Caskaydia%20Cove%20Regular%20Nerd%20Font%20Complete%20Windows%20Compatible.otf' `
  -FontName 'CaskaydiaCove NF Regular'

# Ensure SSH config exists so it can be linked to WSL
if (-Not (Test-Path $HOME\.ssh)) { New-Item $HOME\.ssh -ItemType Directory | Out-Null }

# Ensure .kube\config exists so it can be linked to WSL
if (-Not (Test-Path "$env:USERPROFILE\.kube")) { New-Item "$env:USERPROFILE\.kube" -ItemType Directory | Out-Null }
if (-Not (Test-Path "$env:USERPROFILE\.kube\config")) { New-Item "$env:USERPROFILE\.kube\config" -ItemType File | Out-Null }
$env:KUBECONFIG = "$env:USERPROFILE\.kube\config"
[Environment]::SetEnvironmentVariable('KUBECONFIG', $env:KUBECONFIG, 'User')

