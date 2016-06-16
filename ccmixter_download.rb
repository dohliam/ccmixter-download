#!/usr/bin/ruby

require 'fileutils'
require 'open-uri'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "\n  ==ccmixter-download - a tool for batch downloading and streaming songs from ccMixter==\n  Usage: ccmixter_download_artist.rb [OPTIONS]"

  opts.on("-c", "--license LICENSE", "Filter tracks by license") { |v| options[:license] = v }
  opts.on("-d", "--download", "Download all tracks") { options[:download] = true }
  opts.on("-f", "--save-to-file", "Save urls to tracklist file") { options[:save] = true }
  opts.on("-l", "--limit NUMBER", "Specify results limit (default 200)") { |v| options[:limit] = v }
  opts.on("-m", "--markdown", "Print out playlist in markdown format with links") { options[:markdown] = true }
  opts.on("-p", "--print", "Print tracklist") { options[:print] = true }
  opts.on("-q", "--query KEYWORD", "Search for a keyword") { |v| options[:search] = v }
  opts.on("-r", "--recommended", "Sort by highest recommended uploads") { options[:recommended] = true }
  opts.on("-s", "--stream", "Stream entire playlist (requires mplayer)") { options[:stream] = true }
  opts.on("-t", "--tag TAG", "Specify tag name") { |v| options[:tag] = v }
  opts.on("-u", "--user USER", "Specify user name") { |v| options[:user] = v }
  opts.on("-w", "--raw", "Output raw track array values (debugging)") { options[:raw] = true }

end.parse!

def get_url_content(params)
  url = "http://ccmixter.org/api/query?f=html&t=links_by_dl_ul&chop=0" + params
  open(URI.encode(url)).read
end

def get_track_list(params)
  content = get_url_content(params)
  content.scan(/<a href="(http:\/\/ccmixter.org\/content\/.*?)">/)
end

def download_all_tracks(params, descriptor)
  mp3 = get_track_list(params)

  download_count = 1
  puts "  ** Fetching remote mp3s..."
  mp3.uniq.each do |m|
    filename = m[0].gsub(/.*\//, "")
    FileUtils.mkdir_p descriptor
    progress = download_count.to_f / mp3.uniq.length.to_f * 100
    File.write(descriptor + "/" + filename, open(m[0]).read, {mode: 'wb'})
    puts "  ##{download_count.to_s} of #{mp3.uniq.length.to_s}: #{filename} saved to #{descriptor} directory! (#{progress.round(2).to_s}%)"
    download_count += 1
  end
  puts "  ** All files saved to download folder!"
end

def tracklist_to_file(params, filename)
  mp3 = get_track_list(params)

  mp3.uniq.each do |m|
    File.open(filename, "w") { |f| f << mp3.join("\n") }
  end
end

def save_tracklist(params, basename)
  filename = basename + ".txt"
  tracklist_to_file(params, filename)
  puts "  ** Tracklist saved to #{filename}!"
end

def stream_playlist(params, basename)
  filename = "/tmp/" + basename + ".tmp"

  tracklist_to_file(params, filename)

  exec("mplayer -playlist #{filename}")
end

def print_tracklist(params)
  mp3 = get_track_list(params)

  mp3.uniq.each do |m|
    puts m
  end
end

def raw_tracklist(params)
  mp3 = get_track_list(params)

  mp3.uniq.each do |m|
    p m
  end
end

def get_track_info(params)
  content = get_url_content(params)

  content.scan(/^\s+<li>\n\s+<a href="(http:\/\/ccmixter.org\/files\/.*?\/.*?)" class="cc_file_link">(.*?)<\/a>by     <a href="(http:\/\/ccmixter.org\/people\/.*?)">(.*?)<\/a>\n\s+<a href="(http:\/\/ccmixter.org\/content\/.*?)">(.*?)<\/a>\n\s+<\/li>/)
end

def print_markdown(params)
  info = get_track_info(params)

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

def get_descriptor(desc_array)
  desc = "untitled"
  join = desc_array.join("@").gsub(/(^@+)|(@+$)/, "").gsub(/@+/, "_").gsub(/ /, "-")

  if join != ""
    desc = join
  end
  desc
end

params = ""
user = ""
tag = ""
search = ""
license = ""
limit = ""
sort = ""
desc_arr = ["", "", "", ""]

if options[:limit]
  limit = "&limit=" + options[:limit]
end

if options[:recommended]
  sort = "&sort=num_scores"
end

if options[:user]
  user = "&u=" + options[:user]
  desc_arr[0] = options[:user]
end

if options[:tag]
  tag = "&tags=" + options[:tag]
  desc_arr[1] = options[:tag]
end

if options[:search]
  kw = options[:search]
  search = "&search=" + kw.gsub(/ /, "+") + "&search_type=match"
  desc_arr[2] = kw
end

if options[:license]
  license = "&lic=" + options[:license]
  desc_arr[3] = options[:license]
end

descriptor = get_descriptor(desc_arr)
basename = descriptor + "_ccmixter_tracklist"

params = user + tag + search + license + limit + sort

if params == ""
  puts "  ** No arguments specified. Please use the -h option for help."
  exit
end

if options[:download]
  download_all_tracks(params, basename)
elsif options[:save]
  save_tracklist(params, basename)
elsif options[:print]
  print_tracklist(params)
elsif options[:markdown]
  print_markdown(params)
elsif options[:stream]
  stream_playlist(params, basename)
elsif options[:raw]
  raw_tracklist(params)
else
  puts get_track_list(params)
end
