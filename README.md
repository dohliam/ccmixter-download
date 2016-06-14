# ccmixter-download - A tool for batch downloading and streaming songs from ccMixter

There is a lot of great open-licensed music on [ccMixter](http://ccmixter.org/), but it isn't very easy to download all tracks uploaded by a particular artist or with a particular tag. This script allows you to download songs and stream entire playlists by specifying the artist or tag name.

## Usage

    ccmixter_download.rb [OPTIONS] [ARTIST]

You might want to rename the script to `ccm` and place it in your PATH. This will allow you to do for example:

    ccm -s F_Fact

Which will stream a playlist of all tracks uploaded by user [F_Fact](http://ccmixter.org/people/F_Fact/profile).

The examples below will assume that you have renamed the executable to `ccm`.

## Options
* `-d` (`--download`): _Download all tracks_
* `-f` (`--save-to-file`): _Save urls to tracklist file_
* `-h` (`--help`): _Show help_
* `-l` (`--limit NUMBER`): _Specify results limit (default 200)_
* `-m` (`--markdown`): _Print out playlist in markdown format with links_
* `-p` (`--print`): _Print tracklist_
* `-q` (`--query`): _Search for a keyword_
* `-r` (`--raw`): _Output raw track array values (debugging)_
* `-s` (`--stream`): _Stream entire playlist (requires mplayer)_
* `-t` (`--tag`): _Specify tag instead of artist name_

### Tags

By default using `ccm` and a search term will give results for a specific artist. To show results for a tag instead you can use the `-t` option.

The `-t` option to use tags can be used together with `-d`, `-f`, `p`, `-r`, and `-s` to download, save, print, output raw values or stream music based on a specific tag. For example, to stream a list of tracks tagged as "ambient", you could use:

    ccm -ts ambient

To download the tracks instead, use:

    ccm -td ambient

### Limiting results

The default number of results provided by the ccMixter API is 200. However, many tags (such as `rock`, `hip_hop` or `techno`) and some artists (such as `Javolenus`) can have many more results. In such cases, you can raise the limit using the limit option (`-l`), for example to get the first 500 results from the list of tracks tagged as "techno":

    ccm -tl 500 techno

To get the first 300 tracks by Javolenus:

    ccm -l 300 Javolenus

### Output format

As with tags, the `-m` option can be combined with other options such as `-p`, `-t`, `-l`, and `-q` to produce nicely formatted results in markdown. For example, to get a markdown list of 300 tracks with the tag "jazz", use:

    ccm -tml 300 jazz

## To do

* Filter by license
* Search for remixes of a specific track
* Play random track
* Specify date range
* Sort by highest recommended uploads
* Combine multiple search terms

## License

MIT.
