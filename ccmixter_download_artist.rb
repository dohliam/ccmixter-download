#!/usr/bin/ruby

require 'fileutils'
require 'open-uri'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "\n  ==ccmixter-download-artist - a tool for batch downloading songs from ccMixter==\n  Usage: ccmixter_download_artist.rb [ARTIST] [OPTIONS]"

  opts.on("-d", "--download", "Download all tracks") { options[:download] = true }
  opts.on("-f", "--save-to-file", "Save urls to tracklist file") { options[:save] = true }
  opts.on("-p", "--print", "Print tracklist") { options[:print] = true }
  opts.on("-r", "--raw", "Output raw track array values (debugging)") { options[:raw] = true }
  opts.on("-s", "--stream", "Stream entire playlist (requires mplayer)") { options[:stream] = true }

end.parse!

def get_mp3_list(artist)
  url = "http://ccmixter.org/people/#{artist}/uploads"

  content = open(url).read

  titles = content.scan(/class="cc_file_link upload_name">(.*)<\/a>/)
  mp3 = content.scan(/href = '(http:\/\/ccmixter.org\/content\/#{artist}\/.*\.mp3)/)

  total_tracks = content.scan(/<span class="page_viewing">Viewing \d+ through \d+ of (\d+)<\/span>/)

  total_tracks_int = total_tracks[0][0].to_i

  mod = total_tracks_int % 15
  last_page_int = total_tracks_int - mod

  total_upload_pages = 0

  if mod == 0
    total_upload_pages = total_tracks_int / 15
  else
    total_upload_pages = total_tracks_int / 15 + 1
  end

  puts "  ** Getting #{mp3.length.to_s} tracks..."

  if total_upload_pages == 1
    puts "  ** Done - List of all files:"
  elsif total_upload_pages == 0
    puts "  ** Something went wrong."
  else
    counter = 2
    while counter < total_upload_pages + 1
      offset = (counter - 1) * 15
      page_url = "http://ccmixter.org/people/#{artist}/uploads?offset=#{offset.to_s}"
      page_content = open(page_url).read
      list = page_content.scan(/href = '(http:\/\/ccmixter.org\/content\/#{artist}\/.*\.mp3)/)
      list.each { |l| mp3.push(l) }
      puts "  ** Getting #{mp3.length.to_s} track listings..."

      counter += 1
    end
    puts "  ** Got #{mp3.length.to_s} track listings in total"
  end
  mp3
end

def download_all_tracks(artist)
  mp3 = get_mp3_list(artist)
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
  mp3 = get_mp3_list(artist)
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
  mp3 = get_mp3_list(artist)
  mp3.uniq.each do |m|
    puts m
  end
end

def raw_tracklist(artist)
  mp3 = get_mp3_list(artist)
  mp3.uniq.each do |m|
    p m
  end
end

artist = ""

if ARGV[0]
  artist = ARGV[0]
else
  puts "  ** No argument specified. Please use the -h option for help"
  exit
end

if options[:download]
    download_all_tracks(artist)
elsif options[:save]
    save_tracklist(artist)
elsif options[:print]
    print_tracklist(artist)
elsif options[:stream]
    stream_playlist(artist)
elsif options[:raw]
    raw_tracklist(artist)
else
  mp3 = get_mp3_list(artist)
  puts mp3
end
