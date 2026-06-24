# Lance un petit serveur local et ouvre le jeu dans le navigateur.
# Usage : clic droit > "Exécuter avec PowerShell", ou  ./play.ps1
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$port = 8123
$url = "http://localhost:$port/index.html"

function Test-Cmd($name) { $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }

Write-Host "Crepuscule - serveur local sur $url" -ForegroundColor Cyan

if (Test-Cmd "python") {
    Start-Process $url
    python -m http.server $port
}
elseif (Test-Cmd "py") {
    Start-Process $url
    py -m http.server $port
}
elseif (Test-Cmd "npx") {
    Start-Process $url
    npx --yes serve -l $port .
}
else {
    Write-Host "Python introuvable - ouverture directe du fichier (les sons peuvent etre limites selon le navigateur)." -ForegroundColor Yellow
    Start-Process (Join-Path $root "index.html")
}
