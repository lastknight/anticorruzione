require 'rubygems'

require "open-uri"
require 'json'
require 'date'
require 'pp'
require 'redis'

module Enumerable
  def Exception.ignoring_exceptions
    begin
      yield
    rescue Exception => e
      STDERR.puts e.message
    end
  end
  
  def in_parallel(n = 10)
    todo = Queue.new
    ts = (1..n).map{
      Thread.new{
        while x = todo.deq
          Exception.ignoring_exceptions{ yield(x[0]) } 
        end
      }
    }
    each{|x| todo << [x]}
    n.times{ todo << nil }
    ts.each{|t| t.join}
  end
end

r = Redis.new
count = 0

anno = ARGV[0]
anno = 2017 if anno.nil?

files = r.smembers "aggr:successo:#{anno}"

files.each.in_parallel(50) do |f|
  count += 1
  fiscale = r.hget(f, "fiscale")
  xml = r.hget(f, "url")
  xml = "http://" + xml if xml.start_with?("www")

  if !File.exist?("./data_storage/#{anno}_#{fiscale}.xml")
    puts "#{count}. #{anno}_#{fiscale} - [#{xml}]"
    begin
      remote = open(xml)
      File.open("./data_storage/#{anno}_#{fiscale}.xml", "w", :read_timeout=>10) do |f|
        IO.copy_stream(remote, f)
      end
    rescue
      puts "Error in file #{anno}_#{fiscale}"
    end
  end
  
end

