echo "[INFO] Setting up..."
echo "[INFO] Checking path..."
if (Test-Path C:\Windows\Z-ra -ErrorAction SilentlyContinue)
{
	echo "[INFO] Path OK."
}
else
{
	echo "[INFO] Creating path..."
	New-Item -Path C:\Windows\Z-ra -ItemType Directory -ErrorAction Stop
}

sleep 1

echo "[INFO] Checking script..."
if (Test-Path C:\Windows\Z-ra\zlist.ps1)
{
	echo "[INFO] Script OK."
}
else
{
	echo "[INFO] Deploying script..."
	Invoke-Webrequest https://raw.githubusercontent.com/Z-ra/Igor-Blocklist/main/zlist.ps1 -outfile C:\Windows\Z-ra\zlist.ps1
}


echo "[INFO] Checking ST..."
if (Get-ScheduledTask -TaskName "GUpdater" -ErrorAction SilentlyContinue)
{
	echo "[INFO] ST OK."
}
else
{
	echo "[INFO] Importing ST..."
	Invoke-Webrequest https://raw.githubusercontent.com/Z-ra/Igor-Blocklist/main/GUpdater.xml -Outfile C:\Windows\Temp\GUpdater.xml
	Register-ScheduledTask -xml (Get-Content C:\Windows\Temp\GUpdater.xml | Out-String) -TaskName GUpdater -TaskPath "\" -User SYSTEM -Force
}

echo "[INFO] Checking if firewall rule exists..."
sleep 1



if (Get-NetFirewallRule -DisplayName "Igor Block" -ErrorAction SilentlyContinue)
{
	echo "[INFO] Firewall rule found."
}
else
{
	echo "[INFO] Creating firewall rule..."
	New-NetFirewallRule -DisplayName "Igor Block" -Enabled True -Profile Any -Direction Outbound -Action Block -RemoteAddress 35.153.42.68 | Out-Null
	echo "[INFO] Firewall rule created."
	sleep 2
}

echo "[INFO] Blocking websites..."
$BlockList = (Invoke-WebRequest https://raw.githubusercontent.com/Z-ra/Igor-Blocklist/main/blocklist -UseBasicParsing).Content
$BlockListArr = $BlockList.Split([Environment]::NewLine)
$BLA = @()
foreach ($item in $BlockListArr) {$BLA += $item}
for ($num = 0; $num -le $BLA.Length-2; $num++) {$BLB += @($BLA[$num])}
Set-NetFireWallRule -DisplayName "Igor Block" -RemoteAddress $BLB
Invoke-WebRequest https://raw.githubusercontent.com/Z-ra/Igor-Blocklist/main/hosts -Outfile C:\windows\system32\drivers\etc\hosts
echo "[INFO] Websites blocked."
sleep 1
echo "Press any button to exit..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
