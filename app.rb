require 'sinatra'
require 'sinatra/contrib'
require "sinatra/reloader" if development?
require 'redis'
require 'pp'
require 'nokogiri'

$r = Redis.new

def parse_xml(f)
  results = []
  begin
    @doc = Nokogiri::XML(File.open("./data_storage/#{f}.xml"))
    @doc.xpath('//lotto').each do |single|
      l =  Nokogiri::Slop(single.to_s)
      cig           = l.xpath('//cig')
      oggetto       = l.xpath('//oggetto')
      scelta        = l.xpath('//sceltaContraente')
      win_fiscale   = l.xpath('//aggiudicatario/codiceFiscale')
      win_ragione   = l.xpath('//aggiudicatario/ragioneSociale')
      importo       = l.xpath('//importoAggiudicazione')
      results << [cig, oggetto, scelta, win_fiscale, win_ragione, importo]
    end
  rescue
    results << ["Non è stato possibile analizzare i dati di questo DataSet", "", "", "", ""]
  end
  results
end

get '/' do
  redirect "/l190/"
end

get '/l190/*' do |anno|
  anno = 2017 if anno.nil? || anno == ""
  @anno = anno
  @titolo = "AntiCorruzione Legge 190/12 art.1 comma 32 - Anno #{anno}"
  @data = $r.smembers "aggr:#{anno}"
  erb :list_190
end

get '/scheda/*/*' do |fiscale, anno|
  anno = 2017 if anno.nil? || anno == ""
  @anno = anno
  @scheda = $r.hgetall "aggr:#{fiscale}:#{anno}"
  file = "#{anno}_#{@scheda["fiscale"]}"
  @data = parse_xml(file)
  @titolo = "#{@scheda['ragione']} - Dati AntiCorruzione Legge 190/12 art.1 comma 32 - Anno #{anno}"
  
  erb :scheda_190
end
