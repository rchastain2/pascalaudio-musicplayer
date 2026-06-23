# PascalAudio Music Player

Simple command-line music player based upon [PascalAudio](https://github.com/andrewd207/PascalAudio) and [MSEgui](https://github.com/mse-org/mseide-msegui).

![Screenshot](screenshot.png)

Plays all sound files of a directory.

Supported sound formats:

- flac
- m4a
- ogg
- wav

## Usage

```
./player DIRECTORY
```

Keyboard shortcuts:

| Key | Action |
| --- | --- |
| Escape, Q | Quit |
| P | Pause/resume |
| Right, N | Play next file |
| Left | Play previous file |

## Build

Download *PascalAudio*.

```
cd pascalaudio-musicplayer
git clone https://github.com/andrewd207/PascalAudio.git pascalaudio
git clone https://github.com/andrewd207/fpc-pulseaudio.git pulseaudio
```

Open *player/player.prj* in *MSEide* and click on `Project-Make`.
