# Remove-Tapwindows.ps1
#
# Remove all tap-windows adapters from the driver store using PnPutil.exe

Param(
    [switch]$Yes,
    [switch]$Wintun,
    [switch]$Help
)

Function Show-Usage {
    Write-Host
    Write-Host "Usage: Remove-Tapwindows.ps1 [-Wintun] [-Yes] [-Help]"
    Write-Host
    Write-Host "Parameters:"
    Write-Host "    -Yes    Remove drivers instead of just showing what would get removed"
    Write-Host "    -Wintun Remove Wintun drivers instead of tap-windows6 drivers"
    Write-Host "    -Help   Display this help message"
    Write-Host
    Write-host "Disclaimer: USE AT YOUR OWN RISK."
    exit 1
}

if ($Wintun) {
    $provider = "WireGuard LLC"
} else {
    $provider = "TAP-Windows Provider V9"
}

$driverlist = Invoke-Command -ScriptBlock { & C:\Windows\System32\PnPutil.exe -e }

$tap_found = $false

if ($Help) {
	Show-Usage
}

foreach ($line in $driverlist) {
    if ($line.StartsWith("Published name")) {
        $published_name = $line.Replace(" ","").Split(":")[1]
    } elseif ($line.StartsWith("Driver package provider")) {
        if ($line.EndsWith($provider)) {
            $tap_found = $true
            if ($Yes) { & PnPutil.exe -d $published_name }
            else      { Write-Host "Would remove ${published_name}" }
        }
    }
}

if (! $tap_found) {
    Write-Host "No tap-windows drivers found from the driver store."
}