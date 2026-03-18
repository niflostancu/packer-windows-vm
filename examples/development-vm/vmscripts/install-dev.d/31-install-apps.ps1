# Installs basic apps
# @RunAsTask true

# import chocolatey helper for 'refreshenv'
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1

# install git
choco install --no-progress -y git --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'"
refreshenv

# install python3
choco install --no-progress -y python3

# install vscode
choco install --no-progress -y vscode.install

choco install --no-progress -y notepadplusplus.install
choco install --no-progress -y 7zip.install
choco install --no-progress -y firefox
choco install --no-progress -y sysinternals

