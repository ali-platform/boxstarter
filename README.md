# Windows and WSL BoxStarter

To get started, open Microsoft Store and ensure that all packages are updated.  This is needed to get the latest version of winget.

Run these command from a Terminal (Admin Powershell).  Use WinKey-X
```
Invoke-WebRequest -Uri https://github.com/ali-platform/boxstarter/raw/main/.config/dsc/admin.dsc.yaml -OutFile .\admin.dsc.yaml
winget configure --enable
winget configure --file .\admin.dsc.yaml --accept-configuration-agreements
Remove-Item .\admin.dsc.yaml
exit
```

Run these command from a Terminal.  Use WinKey-X.
```
gh auth login --scopes admin:enterprise,admin:org,admin:org_hook,admin:repo_hook,repo,workflow,write:packages,user:email
```

Then run these commands
```
# Get current GitHub username (login)
$GitHubName = gh api user --jq '.name // .login'

# Get all emails from GitHub, then pick the first one containing "acceleratelearning"
$GitHubEmail = gh api user/emails --jq '.[].email' |
    Where-Object { $_ -like "*acceleratelearning*" } |
    Select-Object -First 1

# Dotfiles setup
function dotfiles { git.exe --git-dir=$HOME\.cfg --work-tree=$HOME $args }

git clone --bare "https://github.com/RobCannon/boxstarter.git" $HOME/.cfg
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout -f main
dotfiles push --set-upstream origin main

# Update .gitconfig in $HOME
$GitconfigPath = "$HOME\.gitconfig"
(Get-Content $GitconfigPath) `
    -replace '(^\s*name\s*=\s*).+$', "`$1$GitHubUser" `
    -replace '(^\s*email\s*=\s*).+$', "`$1$GitHubEmail" |
    Set-Content $GitconfigPath -Encoding UTF8

. "$HOME\.local\bin\boxstarter.ps1"
exit
```

Rob's Preferences
```
Invoke-WebRequest -Uri https://github.com/ali-platform/boxstarter/raw/main/.config/dsc/personalize.dsc.yaml -OutFile .\personalize.dsc.yaml
winget configure --file .\personalize.dsc.yaml --accept-configuration-agreements
Remove-Item .\personalize.dsc.yaml
exit
```

To continue and set up WSL, see: https://github.com/ali-platform/dotfiles

