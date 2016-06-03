# ccmixter-download-artist - A tool for batch downloading songs from ccmixter

There is a lot of great open-licensed music on [ccMixter](http://ccmixter.org/), but it isn't very easy to download all tracks uploaded by a particular artist. This script allows you to download songs and stream entire playlists by specifying the artist name.

## Usage

    ccmixter_download_artist.rb [OPTIONS] [ARTIST]

## Options
* `-d` (`--download`): _Download all tracks_
* `-f` (`--save-to-file`): _Save urls to tracklist file_
* `-h` (`--help`): _Show help_
* `-p` (`--print`): _Print tracklist_
* `-r` (`--raw`): _Output raw track array values (debugging)_
* `-s` (`--stream`): _Stream entire playlist (requires mplayer)_

## License

MIT.
