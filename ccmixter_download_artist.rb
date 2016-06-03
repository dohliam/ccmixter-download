#!/usr/bin/ruby

require 'open-uri'
require 'fileutils'

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

def help_text
  puts
  puts "  ==ccmixter-download-artist - a tool for batch downloading songs from ccmixter=="
  puts "  Usage: ccmixter_download_artist.rb [ARTIST] [OPTIONS]"
  puts
  puts "  Options:"
  puts "  -d\tdownload all tracks"
  puts "  -f\tsave urls to tracklist"
  puts "  -h\tshow this help"
  puts "  -p\tprint tracklist"
  puts "  -s\tstream entire playlist (requires mplayer)"
  puts "  -x\toutput raw track array values (debugging)"
  puts
end

if ARGV[0]
  if ARGV[0] == "-h"
    help_text
    exit
  end
else
  puts "  ** No argument specified. Please use the -h option for help"
  exit
end

artist = ARGV[0]

if ARGV[1]
  if ARGV[1] == "-d"
    download_all_tracks(artist)
  elsif ARGV[1] == "-f"
    save_tracklist(artist)
  elsif ARGV[1] == "-h"
    help_text
  elsif ARGV[1] == "-p"
    print_tracklist(artist)
  elsif ARGV[1] == "-s"
    stream_playlist(artist)
  elsif ARGV[1] == "-x"
    raw_tracklist(artist)
  else
    puts "  ** Bad argument specified"
  end
else
  mp3 = get_mp3_list(artist)
  puts mp3
end
