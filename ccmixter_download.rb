#!/usr/bin/ruby

require 'fileutils'
require 'open-uri'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "\n  ==ccmixter-download - a tool for batch downloading and streaming songs from ccMixter==\n  Usage: ccmixter_download_artist.rb [ARTIST] [OPTIONS]"

  opts.on("-d", "--download", "Download all tracks") { options[:download] = true }
  opts.on("-f", "--save-to-file", "Save urls to tracklist file") { options[:save] = true }
  opts.on("-l", "--limit NUMBER", "Specify results limit (default 200)") { |v| options[:limit] = v }
  opts.on("-m", "--markdown", "Print out playlist in markdown format with links") { options[:markdown] = true }
  opts.on("-p", "--print", "Print tracklist") { options[:print] = true }
  opts.on("-q", "--query", "Search for a keyword") { options[:search] = true }
  opts.on("-r", "--raw", "Output raw track array values (debugging)") { options[:raw] = true }
  opts.on("-s", "--stream", "Stream entire playlist (requires mplayer)") { options[:stream] = true }
  opts.on("-t", "--tag", "Specify tag instead of artist name") { options[:tag] = true }

end.parse!

def get_mp3_list(artist)
  url = "http://ccmixter.org/api/query?f=html&t=links_by_dl_ul&u=#{artist}"

  if @limit
    url = "http://ccmixter.org/api/query?f=html&t=links_by_dl_ul&u=#{artist}&limit=#{@limit}"
  end

  content = open(url).read

  titles = content.scan(/class="cc_file_link">(.*)<\/a>/)
  mp3 = content.scan(/<a href="(http:\/\/ccmixter.org\/content\/#{artist}\/.*?)">/)

  mp3
end

def download_all_tracks(term)
  mp3 = []

  if @tag
    mp3 = get_tag_list(term)
  else
    mp3 = get_mp3_list(term)
  end

  download_count = 1
  puts "  ** Fetching remote mp3s..."
  mp3.uniq.each do |m|
    filename = m[0].gsub(/.*\//, "")
    FileUtils.mkdir_p term
    progress = download_count.to_f / mp3.uniq.length.to_f * 100
    File.write(term + "/" + filename, open(m[0]).read, {mode: 'wb'})
    puts "  ##{download_count.to_s} of #{mp3.uniq.length.to_s}: #{filename} saved to #{term} directory! (#{progress.round(2).to_s}%)"
    download_count += 1
  end
  puts "  ** All files saved to download folder!"
end

def tracklist_to_file(term, filename)
  mp3 = []

  if @tag
    mp3 = get_tag_list(term)
  elsif @search
    mp3 = get_search_list(term)
  else
    mp3 = get_mp3_list(term)
  end

  mp3.uniq.each do |m|
    File.open(filename, "w") { |f| f << mp3.join("\n") }
  end
end

def save_tracklist(term)
  filename = "tracklist_#{term}_ccmixter.txt"
  tracklist_to_file(term, filename)
  puts "  ** Tracklist saved to #{filename}!"
end

def stream_playlist(term)
  filename = "/tmp/ccmixter_#{term}.tmp"

  tracklist_to_file(term, filename)

  exec("mplayer -playlist #{filename}")
end

def print_tracklist(term)
  mp3 = []

  if @tag
    mp3 = get_tag_list(term)
  else
    mp3 = get_mp3_list(term)
  end

  mp3.uniq.each do |m|
    puts m
  end
end

def raw_tracklist(term)
  mp3 = []

  if @tag
    mp3 = get_tag_list(term)
  else
    mp3 = get_mp3_list(term)
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

def print_markdown(term)
  limit = ""
  if @limit
    limit = "&limit=#{@limit}"
  end

  url = "http://ccmixter.org/api/query?f=html&t=links_by_dl_ul&u=#{term}" + limit

  if @tag
    url = "http://ccmixter.org/api/query?tags=#{term}&f=html&t=links_by_dl_ul" + limit
  elsif @search
    url = "http://ccmixter.org/api/query?search=#{term}&f=html&t=links_by_dl_ul" + limit
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

def get_search_list(keyword)
  url = "http://ccmixter.org/api/query?search=#{keyword}&f=html&t=links_by_dl_ul"

  if @limit
    url = "http://ccmixter.org/api/query?search=#{keyword}&f=html&t=links_by_dl_ul&limit=#{@limit}"
  end

  content = open(url).read

  mp3 = content.scan(/<a href="(http:\/\/ccmixter.org\/content\/.*?)">/)

  mp3
end

term = ""

if ARGV[0]
  term = URI.encode(ARGV[0])
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

if options[:search]
  @search = true
end

if options[:download]
  download_all_tracks(term)
elsif options[:save]
  save_tracklist(term)
elsif options[:print]
  print_tracklist(term)
elsif options[:markdown]
  print_markdown(term)
elsif options[:stream]
  stream_playlist(term)
elsif options[:raw]
  raw_tracklist(term)
elsif options[:search]
  puts get_search_list(term)
else
  puts @tag ? get_tag_list(term) : get_mp3_list(term)
end
