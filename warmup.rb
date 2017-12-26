require 'rubygems'

require 'json'
require 'date'
require 'pp'
require 'redis'


r = Redis.new

anno = ARGV[0]
anno = 2017 if anno.nil?

file = File.read "./data_storage/l190-#{anno}.json"
list = JSON.parse(file)

counter = 0

ko = 0
ok = 0

list.each do |k|
  counter += 1
  puts "#{counter} --------------------------------"
  puts ragione = k["ragioneSociale"].strip rescue "vuoto"
  puts fiscale = k["codiceFiscale"].strip
  puts pec = k["identificativoPEC"].strip
  puts url = k["url"].strip
  puts raw_data = DateTime.parse(k["dataUltimoTentativoAccessoUrl"])
  puts data = "#{raw_data.day}/#{raw_data.month}/#{raw_data.year}"
  puts esito = k["esitoUltimoTentativoAccessoUrl"].strip
  if esito.include?("fall")
    ko +=1
  elsif esito.include?("succ")
    ok +=1
  end
  
  r.hmset("aggr:#{fiscale}:#{anno}", 
    "ragione", ragione,
    "fiscale", fiscale,
    "pec", pec,
    "url", url,
    "data", data,
    "esito", esito,
    "anno", anno)
  
    r.sadd("aggr:#{anno}", "aggr:#{fiscale}:#{anno}")
    r.sadd("aggr:#{fiscale}", "aggr:#{fiscale}:#{anno}")
    r.sadd("aggr:#{esito}", "aggr:#{fiscale}:#{anno}")
    r.sadd("aggr:#{esito}:#{anno}", "aggr:#{fiscale}:#{anno}")
  
end

