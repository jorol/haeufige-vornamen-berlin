#! /usr/bin/env ruby

require 'date'
require 'json'
require 'optparse'

options = {
    :year => (Date.today.year - 1).to_s
}
usage = "Usage: ruby fill_template.rb TEMPLATE [options]"
OptionParser.new do |opts|
  opts.banner = usage

  opts.on("-v", "--[no-]verbose", "Run verbosely (default is non-verbose, i.e., no output).") do |v|
    options[:verbose] = v
  end

  opts.on("-y", "--year STRING", String, "Year variable to be used everywhere in the data.") do |year|
    options[:year] = year
  end

  opts.on("-r", "--date_released STRING", String, "ISO 8601 date to be used as `date_released`.") do |date_released|
    options[:date_released] = date_released
  end

  opts.on("-u", "--date_updated STRING", String, "ISO 8601 date to be used as `date_updated`.") do |date_updated|
    options[:date_updated] = date_updated
  end
end.parse!

if ARGV.count != 1
  puts usage
  exit
end

options[:template] = ARGV[0]

dates = [ options[:date_released], options[:date_updated] ].compact
date = ""
begin
    dates.each do |_date|
        date = _date
        throw ArgumentError unless date.match(/^\d{4}-\d{2}-\d{2}$/)
        Date.parse(date)
    end
rescue ArgumentError
    puts "Dates need to be valid ISO8601: #{date} != YYYY-MM-DD "
end

begin
    throw ArgumentError unless options[:year].match(/^\d{4}$/)
rescue ArgumentError
    puts "Years need to be YYYY: #{options[:year]}"
end

begin
    data = JSON.parse(File.read(options[:template]), :symbolize_names => true)
rescue
    puts "Could not open or parse '#{options[:template]}'."
end

[:date_released, :date_updated].each do |date_key|
    if options[date_key]
        data[date_key] = options[date_key]
    else
        data.delete(date_key)
    end
end

data[:name] = "liste-der-h-ufigen-vornamen-#{options[:year]}"
data[:temporal_coverage_from] = "#{options[:year]}-01-01"
data[:temporal_coverage_to] = "#{options[:year]}-12-31"
data[:title] = "Liste der häufigen Vornamen #{options[:year]}"

data[:resources].each do |resource|
    resource[:name] = resource[:name].sub(/\d{4}/, options[:year])
    resource[:url] = resource[:url].sub(/^.+\d{4}/, "https://github.com/berlinonline/haeufige-vornamen-berlin/raw/master/data/cleaned/#{options[:year]}")
    case resource[:format]
    when "CSV"
        resource[:description] = "Vollständige Liste aller Vornamen der in #{options[:year]} angemeldeten Kinder im Bezirk. Spaltennamen lauten `vorname`, `anzahl` (Häufigkeit der Kombination `vorname`, `geschlecht`, `position`), `geschlecht` und `position` (keine Rückschlüsse auf Rufnamen des Kindes). Trennzeichen `,`."
    when "PDF"
        resource[:description] = "Liste der häufigsten Vornamen der in #{options[:year]} angemeldeten Kinder im Bezirk."
    end
end

puts JSON.pretty_generate(data)
