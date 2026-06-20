
DIR=/home/roland/Documents/audio/pascalaudio-musicplayer/player-process-console

if [ ! -d "$1" ]; then
  printf "[ERROR] Invalid parameter (directory expected): \"%s\"\n" "$1"
  exit 1
fi

for f in $1/*.{ogg,opus}; do
  if [ -f "$f" ]; then
    printf "[DEBUG] Play \"%s\"\n" "$f"
    ext="${f##*.}"
    if [[ "$ext" == "opus" ]]; then
      $DIR/playopus "$f"
    fi
    if [[ "$ext" == "ogg" ]]; then
      $DIR/playogg "$f"
    fi
  else
    printf "[DEBUG] Ignore \"%s\"\n" "$f"
  fi
done

sleep 3

exit 0

FFMPEG=/home/roland/Applications/ffmpeg-master-latest-linux64-gpl/bin/ffmpeg

for f in *.webm; do
  $FFMPEG -i "$f" -vn -acodec copy "${f%.*}.opus"
done

$FFMPEG -i liebster-jesu-wir-sind-hier-BWV-731.mp4 -vn \
  -acodec libmp3lame -ac 2 -ab 160k -ar 48000 \
  liebster-jesu.mp3
