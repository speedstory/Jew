Clear-Host
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "               JewInstaller      " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$username = [System.Environment]::UserName
$baseDir = "C:\Users\$username\Jew"
$targetDir = "C:\Users\$username\Jew\Jew"
$desktopPath = [System.Environment]::GetFolderPath("Desktop")

$zipUrl = "https://github.com/speedstory/Jew/releases/download/zip/Jew.zip"
$exeUrl = "https://github.com/speedstory/Jew/releases/download/zip/Jew.exe"

$pythonInstalled = $false
$pythonVersionValid = $false
$pythonCmd = "python"

Write-Host "[*] Checking for Python 3.10 or higher..." -ForegroundColor Yellow

foreach ($cmd in @("python3", "python")) {
    try {
        $pyCheck = & $cmd --version 2>&1
        if ($pyCheck -match "Python\s+(\d+)\.(\d+)") {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            $pythonInstalled = $true
            
            if ($major -eq 3 -and $minor -ge 10) {
                $pythonVersionValid = $true
                $pythonCmd = $cmd
                Write-Host "[+] Found compatible Python version ($cmd): 3.$minor" -ForegroundColor Green
                break
            }
        }
    } catch {}
}


if ($pythonInstalled -and $pythonVersionValid) {
    Write-Host "[*] Scenario 1 triggered: Deploying Source Files via ZIP..." -ForegroundColor Cyan
    
    
    if (-not (Test-Path $baseDir)) {
        New-Item -ItemType Directory -Force -Path $baseDir | Out-Null
    }
    
    $zipPath = "$baseDir\Jew.zip"
    
    Write-Host "[*] Downloading Jew.zip..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
    
    Write-Host "[*] Extracting files to $baseDir..." -ForegroundColor Yellow
   
    Expand-Archive -Path $zipPath -DestinationPath $baseDir -Force
    
    
    Remove-Item -Path $zipPath -Force
    
    Write-Host "[+] Installation complete successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "                HOW TO RUN (CLI METHOD)                 " -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "1. Open your Terminal/PowerShell."
    Write-Host "2. Navigate to the project directory using this command:"
    Write-Host "   cd $targetDir" -ForegroundColor Magenta
    Write-Host "3. Start the application by running:"
    Write-Host "   $pythonCmd Jew.py" -ForegroundColor Magenta
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
    
    
    if (Test-Path $targetDir) {
        Set-Location -Path $targetDir
        & $pythonCmd Jew.py
    } else {
        Write-Host "[-] Error: target directory $targetDir not found." -ForegroundColor Red
    }

} 

else {
    Write-Host "[-] Python 3.10+ not detected. Switching to standalone executable mode..." -ForegroundColor Yellow
    Write-Host "[*] Scenario 2 triggered: Deploying Standalone EXE..." -ForegroundColor Cyan
    
    
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    }
    
    $exePath = "$targetDir\Jew.exe"
    
    Write-Host "[*] Downloading Jew.exe..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $exeUrl -OutFile $exePath
    
    
    Write-Host "[*] Creating Desktop Shortcut..." -ForegroundColor Yellow
    $shortcutPath = "$desktopPath\Jew.lnk"
    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $exePath
    $shortcut.WorkingDirectory = $targetDir
    $shortcut.IconLocation = "$exePath,0" # EXE'nin kendi gömülü logosunu kullanır
    $shortcut.Save()
    
    Write-Host "[+] Installation complete successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "                HOW TO RUN (EXE METHOD)                 " -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "• Desktop Shortcut Created: A shortcut named 'Jew' is now on your desktop."
    Write-Host "• How to Launch:"
    Write-Host "  Simply double-click the 'Jew' icon on your desktop to start the application." -ForegroundColor Magenta
    Write-Host "• Alternative CLI Execution:"
    Write-Host "  You can also navigate to: cd $targetDir"
    Write-Host "  And run: .\Jew.exe" -ForegroundColor Magenta
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
}


Read-Host -Prompt "Press Enter to exit..."
