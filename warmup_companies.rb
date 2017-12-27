require 'rubygems'

require 'json'
require 'date'
require 'pp'
require 'redis'
require 'nokogiri'



def parse_xml(f)
  results = []
  begin
    @doc = Nokogiri::XML(File.open("./data_storage/#{f}.xml"))
    @doc.xpath('//lotto').each do |single|
      l =  Nokogiri::Slop(single.to_s)
      cig           = l.xpath('//cig').inner_text
      oggetto       = l.xpath('//oggetto').inner_text
      scelta        = l.xpath('//sceltaContraente').inner_text
      win_fiscale   = l.xpath('//aggiudicatario/codiceFiscale').inner_text
      win_ragione   = l.xpath('//aggiudicatario/ragioneSociale').inner_text
      importo       = l.xpath('//importoAggiudicazione').inner_text
      results << [cig, oggetto, scelta, win_fiscale, win_ragione, importo]
    end
  rescue
    results << ["Non è stato possibile analizzare i dati di questo DataSet", "", "", "", ""]
  end
  results
end

r = Redis.new
count = 0

files = r.smembers "aggr:successo"

files.each do |f|
  #@scheda = $r.hgetall "aggr:#{fiscale}:#{anno}"
  fiscale = r.hget(f, "fiscale")
  anno = r.hget(f, "anno")
  ragione = r.hget(f, "ragione")
  
  puts "Parsing #{f} (#{ragione}, #{fiscale}, #{anno})------------------------------"
  
  if File.exist?("./data_storage/#{anno}_#{fiscale}.xml")
    
    lotti = parse_xml("#{anno}_#{fiscale}")
    
    if lotti.size > 0 && !lotti.first[0].start_with?("Non è stato")
      
      lotti.each do |l|
        puts "\t#{l[5]} -> #{l[4]}"
        
        r.hmset("company:#{l[3]}", 
          "ragione", l[4],
          "fiscale", l[3])
        
        open("./company_storage/company_#{l[3]}", 'a') { |f|
          f.puts "#{l[0]}||#{l[1]}||#{l[2]}||#{l[3]}||#{l[4]}||#{l[5]}||#{anno}_#{fiscale}"
        }
      end

    else
      puts "   ...No data!"
    end
  end rescue nil
  
end

    
#    r.hmset("azienda:#{fiscale}",
#      "ragione", ragione,
#      "fiscale", fiscale)
#      
#    r.hmset("aggr:#{fiscale}:#{anno}", 
#      "ragione", ragione,
#      "fiscale", fiscale,
#      "pec", pec,
#      "url", url,
#      "data", data,
#      "esito", esito,
#      "anno", anno)
#  
#      r.sadd("aggr:#{anno}", "aggr:#{fiscale}:#{anno}")