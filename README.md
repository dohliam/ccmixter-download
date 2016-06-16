# ccmixter-download - A tool for batch downloading and streaming songs from ccMixter

There is a lot of great open-licensed music on [ccMixter](http://ccmixter.org/), but it isn't very easy to download all tracks uploaded by a particular artist or with a particular tag. This script allows you to download songs and stream entire playlists by specifying the artist or tag name.

## Usage

    ccmixter_download.rb [OPTIONS] [ARTIST]

You might want to rename the script to `ccm` and place it in your PATH. This will allow you to do for example:

    ccm -su F_Fact

Which will begin streaming a playlist of all tracks uploaded by user [F_Fact](http://ccmixter.org/people/F_Fact/profile).

For the sake of convenience, the examples below will assume that you have renamed the executable to `ccm`.

## Options

Options can be used individually or combined together to produce more fine grained results. The following options are available:

* `-c`, (`--license LICENSE`): _Filter tracks by license_
* `-d`, (`--download`): _Download all tracks_
* `-f`, (`--save-to-file`): _Save urls to tracklist file_
* `-l`, (`--limit NUMBER`): _Specify results limit (default 200)_
* `-m`, (`--markdown`): _Print out playlist in markdown format with links_
* `-p`, (`--print`): _Print tracklist_
* `-q`, (`--query KEYWORD`): _Search for a keyword_
* `-r`, (`--recommended`): _Sort by highest recommended uploads_
* `-s`, (`--stream`): _Stream entire playlist (requires mplayer)_
* `-t`, (`--tag TAG`): _Specify tag name_
* `-u`, (`--user USER`): _Specify user name_
* `-w`, (`--raw`): _Output raw track array values (debugging)_

### Users

To get all tracks uploaded by a particular user, use the `-u` option, for example:

    ccm -u teru

The above command will print out a list of tracks uploaded by user `teru`.

This can be combined with other options to refine the list of results to a particular tag (`-t`) or sort according to number of recommendations (`-r`), as well as save the results to a playlist (`-s`) or download all files to disk (`-d`). Further examples are below.

### Tags

To get results for a specific tag you can use the `-t` option. This option can be used together with `-d`, `-f`, `p`, `-r`, and `-s` to download, save, print, output raw values or stream music based on a specific tag. For example, to stream a list of tracks tagged as "ambient", you could use:

    ccm -st ambient

To download the tracks instead, use:

    ccm -dt ambient

You can specify multiple tags by separating them with a space or a `+`:

    ccm -t "celtic+electro+remix"

    ccm -t "funk jazz saxophone chill trip_hop"

### Keyword search

You can search for an exact phrase, term, or title in track metadata using the `-q` option:

    ccm -q "Violet Fusion"

As always, this can be combined with other options to refine the search:

    ccm -u grapes -q dunno

### Limiting results

The default number of results provided by the ccMixter API is 200. However, many tags (such as `rock`, `hip_hop` or `techno`) and some artists (such as `Javolenus`) can have many more results. In such cases, you can raise the limit using the limit option (`-l`), for example to get the first 500 results from the list of tracks tagged as "techno":

    ccm -l 500 -t techno

Similarly, to get the first 300 tracks by Javolenus:

    ccm -l 300 -u Javolenus

### Filter by license

You can use the license option (`-c`) to filter the results for a given search by license. Only tracks with the specified license will be returned.

For example, to display a list of tracks tagged as "blues" that are released under a CC-BY license, you can use:

    ccm -t blues -c by

The possibe license values are:

Value | License name
----- | ------------
`by` | Attribution (CC BY)
`nc` | NonCommercial (CC BY-NC)
`sa` | ShareAlike (CC BY-SA)
`nod` | NoDerivs (CC BY-ND)
`byncsa` | NonCommercial ShareAlike (CC BY-NC-SA)
`byncnd` | Attribution-NonCommercial-NoDerivs (CC BY-NC-ND)
`s` | Sampling
`splus` | Sampling+
`ncsplus` | NonCommercial Sampling+
`pd` | Public Domain (CC 0)

### Output format

The default output format (e.g. for the `-p` or `-f` options) is a plain text list of download urls, separated by line breaks. However other output formats (e.g. markdown, raw) are also available.

As with tags, the `-m` option can be combined with other options such as `-p`, `-t`, `-l`, and `-q` to produce nicely formatted results in markdown. For example, to get a markdown list of 300 tracks with the tag "jazz", use:

    ccm -ml 300 -t jazz

For debugging purposes, the `-w` option outputs the track list in raw format (i.e., as an array of strings).

## To do

* Search for remixes of a specific track
* Play random track
* Specify date range

## License

MIT.
