#!/bin/sh

# Configuration
DATA_DIR="/data"
M3U_URL="https://raw.githubusercontent.com/junguler/m3u-radio-music-playlists/refs/heads/main/---everything-checked-repo.m3u"
M3U_FILE="$DATA_DIR/radios.m3u"
SQL_FILE="$DATA_DIR/insert_radios.sql"

# Create data directory if needed
mkdir -p "$DATA_DIR"

echo "Downloading M3U file..."
curl -s "$M3U_URL" -o "$M3U_FILE"

# Check if file exists and is not empty
if [ ! -s "$M3U_FILE" ]; then
  echo "Error: M3U file is empty or could not be downloaded"
  exit 1
fi

# Count total EXTINF entries (stations)
TOTAL=$(grep -c "^#EXTINF" "$M3U_FILE")

echo "Preparing SQL file... (if you have a very large .m3u, this may take up to 10 minutes)"
echo "Total stations detected: $TOTAL"

# Start SQL file
cat > "$SQL_FILE" <<EOF
BEGIN TRANSACTION;

DELETE FROM radio;

COMMIT;
BEGIN TRANSACTION;
EOF

id=1
count=0
created_at=$(date +"%Y-%m-%d %H:%M:%S")

# Read the M3U file two lines at a time: EXTINF + stream URL
while read -r extinf && read -r stream_url; do

  # Process only EXTINF entries
  echo "$extinf" | grep -q "^#EXTINF" || continue

  count=$((count + 1))

  # Skip playlist URLs (.m3u or .m3u8)
  echo "$stream_url" | grep -Eiq '\.m3u8?(\?|$)' && continue

  # Extract station name, trim spaces, escape quotes
  name=$(echo "$extinf" \
    | sed 's/^.*,//' \
    | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
    | sed "s/'/''/g")

  # Escape single quotes in URL
  stream_url=$(echo "$stream_url" | sed "s/'/''/g")

  # Generate INSERT statement
  echo "INSERT INTO radio (id, name, stream_url, created_at, updated_at) \
VALUES ($id, '$name', '$stream_url', '$created_at', '$created_at') \
ON CONFLICT(name) DO UPDATE SET \
  stream_url = excluded.stream_url, \
  updated_at = excluded.updated_at;" >> "$SQL_FILE"

  id=$((id + 1))

  # Show progress (same line)
  printf "\rGenerating SQL file... %d / %d" "$count" "$TOTAL"

done < "$M3U_FILE"

# End transaction
echo "\nCOMMIT;" >> "$SQL_FILE"

echo ""
echo "Done."
echo "SQL file generated: $SQL_FILE"

