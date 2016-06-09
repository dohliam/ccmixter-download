#!/usr/bin/ruby

require 'fileutils'
require 'open-uri'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "\n  ==ccmixter-download - a tool for batch downloading and streaming songs from ccMixter==\n  Usage: ccmixter_download_artist.rb [ARTIST] [OPTIONS]"

  opts.on("-d", "--download", "Download all tracks") { options[:download] = true }
  opts.on("-f", "--save-to-file", "Save urls to tracklist file") { options[:save] = true }
  opts.on("-l", "--limit NUMBER", "Specify results limit for tags (default 200)") { |v| options[:limit] = v }
  opts.on("-m", "--markdown", "Print out playlist in markdown format with links") { options[:markdown] = true }
  opts.on("-p", "--print", "Print tracklist") { options[:print] = true }
  opts.on("-r", "--raw", "Output raw track array values (debugging)") { options[:raw] = true }
  opts.on("-s", "--stream", "Stream entire playlist (requires mplayer)") { options[:stream] = true }
  opts.on("-t", "--tag", "Specify tag instead of artist name") { options[:tag] = true }

end.parse!

def get_mp3_list(artist)
  url = "http://ccmixter.org/api/query?f=html&t=links_by_dl_ul&u=#{artist}"

  content = open(url).read

  titles = content.scan(/class="cc_file_link">(.*)<\/a>/)
  mp3 = content.scan(/<a href="(http:\/\/ccmixter.org\/content\/#{artist}\/.*?)">/)

  mp3
end

def download_all_tracks(artist)
  mp3 = []

  if @tag
    mp3 = get_tag_list(artist)
  else
    mp3 = get_mp3_list(artist)
  end

  download_count = 1
  puts "  ** Fetching remote mp3s..."
  mp3.uniq.each do |m|
    filename = m[0].gsub(/.*\//, "")
    FileUtils.mkdir_p artist
    progress = download_count.to_f / mp3.uniq.length.to_f * 100
    File.write(artist + "/" + filename, open(m[0]).read, {mode: 'wb'})
    puts "  ##{download_count.to_s} of #{mp3.uniq.length.to_s}: #{filename} saved to #{artist} directory! (#{progress.round(2).to_s}%)"
    download_count += 1
  end
  puts "  ** All files saved to download folder!"
end

def tracklist_to_file(artist, filename)
  mp3 = []

  if @tag
    mp3 = get_tag_list(artist)
  else
    mp3 = get_mp3_list(artist)
  end

  mp3.uniq.each do |m|
    File.open(filename, "w") { |f| f << mp3.join("\n") }
  end
end

def save_tracklist(artist)
  filename = "tracklist_#{artist}_ccmixter.txt"
  tracklist_to_file(artist, filename)
  puts "  ** Tracklist saved to #{filename}!"
end

def stream_playlist(artist)
  filename = "/tmp/ccmixter_#{artist}.tmp"

  tracklist_to_file(artist, filename)

  exec("mplayer -playlist #{filename}")
end

def print_tracklist(artist)
  mp3 = []

  if @tag
    mp3 = get_tag_list(artist)
  else
    mp3 = get_mp3_list(artist)
  end

  mp3.uniq.each do |m|
    puts m
  end
end

def raw_tracklist(artist)
  mp3 = []

  if @tag
    mp3 = get_tag_list(artist)
  else
    mp3 = get_mp3_list(artist)
  end

  mp3.uniq.each do |m|
    p m
  end
end

def get_tag_list(tag)
  url = "http://ccmixter.org/api/query?tags=#{tag}&f=html&t=links_by_dl_ul"

  if @limit
    url = "http://ccmixter.org/api/query?tags=#{tag}&f=html&t=links_by_dl_ul&limit=#{@limit}"
  end

  content = open(url).read

  mp3 = content.scan(/<a href="(http:\/\/ccmixter.org\/content\/.*?)">/)

  mp3
end

def print_markdown(artist)
  url = "http://ccmixter.org/api/query?f=html&t=links_by_dl_ul&u=#{artist}"

  if @tag
    url = "http://ccmixter.org/api/query?tags=#{artist}&f=html&t=links_by_dl_ul"
  end

  if @limit
    url = "http://ccmixter.org/api/query?tags=#{artist}&f=html&t=links_by_dl_ul&limit=#{@limit}"
  end

  content = open(url).read

  info = content.scan(/^\s+<li>\n\s+<a href="(http:\/\/ccmixter.org\/files\/.*?\/.*?)" class="cc_file_link">(.*?)<\/a>by     <a href="(http:\/\/ccmixter.org\/people\/.*?)">(.*?)<\/a>\n\s+<a href="(http:\/\/ccmixter.org\/content\/.*?)">(.*?)<\/a>\n\s+<\/li>/)

  info.each do |i|
    ccmixter_link = i[0]
    title = i[1]
    artist_link = i[2]
    artist_name = i[3]
    file_download_link = i[4]
    file_type = i[5]

    puts "* _[#{title}](#{ccmixter_link})_: **[#{artist_name}](#{artist_link})** ([#{file_type}](#{file_download_link}))\n"
  end
end

artist = ""

if ARGV[0]
  artist = ARGV[0]
else
  puts "  ** No argument specified. Please use the -h option for help"
  exit
end

if options[:tag]
  @tag = true
end

if options[:limit]
  @limit = options[:limit]
end

if options[:download]
  download_all_tracks(artist)
elsif options[:save]
  save_tracklist(artist)
elsif options[:print]
  print_tracklist(artist)
elsif options[:markdown]
  print_markdown(artist)
elsif options[:stream]
  stream_playlist(artist)
elsif options[:raw]
  raw_tracklist(artist)
else
  puts @tag ? get_tag_list(artist) : get_mp3_list(artist)
end
