# Windows and WSL BoxStarter

To get started, from Windows PowerShell, install pwsh, git and gh command lines
```
winget install -e --id Microsoft.PowerShell
winget install -e --id Git.Git
winget install -e --id GitHub.cli

```

Exit powershell and start powershell core prompt
```
function dtf { git.exe --git-dir=$HOME\.cfg --work-tree=$HOME $args }
git clone --bare "https://github.com/RobCannon/boxstarter.git" $HOME/.cfg
dtf config --local status.showUntrackedFiles no
dtf checkout -f main
dtf push --set-upstream origin main

$HOME/.local/bin/boxstarter.ps1

```