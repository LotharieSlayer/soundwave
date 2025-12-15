#!/bin/sh

# Configuration
DATA_DIR="/data"
M3U_URL="https://raw.githubusercontent.com/junguler/m3u-radio-music-playlists/refs/heads/main/---everything-checked-repo.m3u"
M3U_FILE="$DATA_DIR/radios.m3u"
SQL_FILE="$DATA_DIR/insert_radios.sql"

mkdir -p "$DATA_DIR"

echo "Téléchargement du fichier M3U..."
curl -s "$M3U_URL" -o "$M3U_FILE"

if [ ! -s "$M3U_FILE" ]; then
  echo "Erreur : fichier M3U vide ou non téléchargé"
  exit 1
fi

echo "Génération du fichier SQL... (Cela peut prendre jusqu'à 10min)"
echo "BEGIN TRANSACTION;" > "$SQL_FILE"

id=1
created_at=$(date +"%Y-%m-%d %H:%M:%S")

# Lecture du fichier deux lignes par deux lignes
while read -r extinf && read -r stream_url; do
  # On ne traite que les lignes EXTINF
  echo "$extinf" | grep -q "^#EXTINF" || continue

  # Extraction du nom (après la dernière virgule)
  name=$(echo "$extinf" | sed 's/^.*,//' | sed "s/'/''/g")

  # Sécurisation de l'URL
  stream_url=$(echo "$stream_url" | sed "s/'/''/g")

  echo "INSERT INTO radio (id, name, stream_url, created_at, updated_at) VALUES ($id, '$name', '$stream_url', '$created_at', '$created_at');" >> "$SQL_FILE"

  id=$((id + 1))
done < "$M3U_FILE"

echo "COMMIT;" >> "$SQL_FILE"

echo "Terminé."
echo "Fichier SQL généré : $SQL_FILE"

