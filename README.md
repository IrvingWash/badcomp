# badcomp

This app changes Bandcamp album's file """structure""" into a nice format.

How it looks by default:
```
'CASTEVET - Obsian'
├── 'CASTEVET - Obsian - 01 The Tower.mp3'
├── 'CASTEVET - Obsian - 02 Cavernous.mp3'
├── 'CASTEVET - Obsian - 03 The Curve.mp3'
├── 'CASTEVET - Obsian - 04 As Fathomed By Beggars And Victims.mp3'
├── 'CASTEVET - Obsian - 05 Obsian.mp3'
├── 'CASTEVET - Obsian - 06 The Seat Of Severance.mp3'
└── cover.jpg
```
Sucks, doesn't it?

And this is how it looks after a `badcomp -s ~/Downloads/CASTEVET - Obsian/ -d ~/Music`:
```
CASTEVET
└── '2013 - Obsian'
    ├── '01. The Tower.mp3'
    ├── '02. Cavernous.mp3'
    ├── '03. The Curve.mp3'
    ├── '04. As Fathomed By Beggars And Victims.mp3'
    ├── '05. Obsian.mp3'
    ├── '06. The Seat Of Severance.mp3'
    └── cover.jpg
```

## Flags
-s, --source        - source directory, i.e. unzipped Bandcamp album
-d, --destination   - destination directory, for example '~/Music'. The artist name directory is created automatically, and it works fine if you already have a directory with that artist's name
-r, --remove-source - delete the source directory after completion.
