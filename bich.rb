#!/usr/bin/env ruby

require 'fileutils'

class Bich

  OUTPUT_FOLDER = 'new_files'
  OLD_FOLDER    = 'old'

  def initialize(file_path, narrator: nil)
    @file_path = file_path
    @narrator_regex = case narrator
    when :easy; /[A-Z -]+: /
    else /[\w ]+: /
    end
  end

  def read_file
    # File.read(@file_path)
    File.open(@file_path, 'r:UTF-8').read
  end

  def fix_spaces(line)
    line.squeeze(' ').strip
  end

  def fix_content(content)
    rows_array = content.split("\n")
    rows_array.map! do |line|
      line = line.gsub(/\[.*\]/,'')
      line = line.gsub(@narrator_regex,'')

      fix_spaces(line)
    end.reject! do |line|
      line !~ /[\wא-ת]/
      # not(line =~ /[\w]/ || line =~ /[א-ת]/)
    end
    # puts "rows_array: #{rows_array.inspect}"
    rows_array.compact.join("\n")
  end

  def convert_file
    read_file.gsub(/(\d+\n\d{2}:\d{2}:\d{2},\d{3} --> \d{2}:\d{2}:\d{2},\d{3}\n)(.*?)(?=(?:\n\n|\n\z))/m) do |m|
      "#{$1}#{fix_content($2)}"
    end
  end

  def export(out_file:)
    File.open(out_file, 'w') {|f| f.write(convert_file) }
  end

  def self.run(output_folder: 'new_files')
    # fetch srt file:
    srt_files = Dir.entries('.')[2..-1].sort.select{|entry| entry.end_with?('.srt')}

    srt_files.each do |srt_file|
      if false # use new folder
        old_folder_file_path = File.join(OLD_FOLDER, srt_file)
        FileUtils.mv(srt_file, old_folder_file_path)

        output_file_path = File.join(OUTPUT_FOLDER, srt_file)
        Bich.new(old_folder_file_path).export(out_file: output_file_path)
      else # use current folder
        old_folder_file_path = File.join(OLD_FOLDER, srt_file)
        FileUtils.mv(srt_file, old_folder_file_path)

        Bich.new(old_folder_file_path).export(out_file: srt_file)
      end
    end

    # move srt_files to old folder:
  end


end

Bich.run

# a.export(out_file: '3.srt')
