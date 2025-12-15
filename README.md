# Soundwave
Add a lot of webradios to your [Navidrome server](https://github.com/navidrome/navidrome)

## Installation
1. Set M3U_URL in [update_radios.sh](https://github.com/LotharieSlayer/soundwave/blob/main/update_radios.sh)
2. **Down your Navidrome container for safety**
3. Run the Dockerfile
4. Wait until .sql finish generating
6. Dump **AND BACKUP** your `navidrome.db` elsewhere
7. Insert radios with `sqlite3 navidrome.db < insert_radios.sql` manually (or automate it by adding the line into [update_radios.sh](https://github.com/LotharieSlayer/soundwave/blob/main/update_radios.sh)
8. Up your Navidrome container
9. Enjoy!

## Docker Volume
Add a volume like this if you want to automate the process by letting access to Navidrome data folder.
`/navidrome_data:/data`

## Webradios lists
Go check out [junguler/m3u-radio-music-playlists](https://github.com/junguler/m3u-radio-music-playlists) !
