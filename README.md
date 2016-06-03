# ccmixter-download - A tool for batch downloading and streaming songs from ccMixter

There is a lot of great open-licensed music on [ccMixter](http://ccmixter.org/), but it isn't very easy to download all tracks uploaded by a particular artist. This script allows you to download songs and stream entire playlists by specifying the artist name.

## Usage

    ccmixter_download.rb [OPTIONS] [ARTIST]

## Options
* `-d` (`--download`): _Download all tracks_
* `-f` (`--save-to-file`): _Save urls to tracklist file_
* `-h` (`--help`): _Show help_
* `-p` (`--print`): _Print tracklist_
* `-r` (`--raw`): _Output raw track array values (debugging)_
* `-s` (`--stream`): _Stream entire playlist (requires mplayer)_
* `-t` (`--tag`): _Specify tag instead of artist name_

The `-t` option to use tags can be used together with `-d`, `-f`, `p`, `-r`, and `-s` to download, save, print, output raw values or stream music based on a specific tag. For example, to stream a list of tracks tagged as "ambient", you could use:

    ccmixter_download.rb -ts ambient

To download the tracks instead, use:

    ccmixter_download.rb -td ambient

## License

MIT.
