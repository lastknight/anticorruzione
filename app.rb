require 'sinatra'
require 'sinatra/contrib'
require "sinatra/reloader" if development?
require 'redis'
require 'pp'
require 'nokogiri'

$r = Redis.new

class Numeric
  def to_currency( pre_symbol='€', thousands='.', decimal=',',
post_symbol=nil )
    "#{pre_symbol}#{
      ( "%.2f" % self ).gsub(
        /(\d)(?=(?:\d{3})+(?:$|\.))/,
        "\\1#{thousands}"
      )
    }#{post_symbol}"
  end
end

def num_to_currency price
  price
  if !price.nil?
    price = price.to_f.to_currency 
  else
    price = 0.to_currency 
  end
  price
end

def parse_azienda(f)
  results = []
  File.open("./company_storage/company_#{f}", "r") do |f|
    f.each_line do |line|
      results << line.split("||")
    end
  end rescue nil
  results
end

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
  
  @totale
  @totale_diretto
  @totale_cottimo
  
  @data.each do |d|
    if !d[5].nil?
      prezzo = d[5].to_f
      begin
        @totale = @totale + prezzo
      rescue
        @totale = prezzo
      end
    end
  end

  @data.each do |d|
    if !d[5].nil? && d[2].start_with?("23")
      prezzo = d[5].to_f
      begin
        @totale_diretto = @totale_diretto + prezzo
      rescue
        @totale_diretto = prezzo
      end
    end
  end
  
  @data.each do |d|
    if !d[6].nil? && d[2].start_with?("08")
      prezzo = d[5].to_f
      begin
        @totale_cottimo = @totale_cottimo + prezzo
      rescue
        @totale_cottimo = prezzo
      end
    end
  end
  
  @titolo = "#{@scheda['ragione']} - Dati AntiCorruzione Legge 190/12 art.1 comma 32 - Anno #{anno}"
  
  erb :scheda_190
end

get '/azienda/*' do |fiscale|
  @scheda = $r.hgetall "company:#{fiscale}"
  @data = parse_azienda(fiscale).sort_by(&:last).reverse
  
  @totale = {}
  @totale_diretto = {}
  @totale_cottimo = {}
  
  @data.each do |d|
    if !d[6].nil?
      anno = d[6].split("_")[0].to_s
      prezzo = d[5].to_f
      begin
        @totale[anno] = @totale[anno] + prezzo
      rescue
        @totale[anno] = prezzo
      end
    end
  end

  @data.each do |d|
    if !d[6].nil? && d[2].start_with?("23")
      anno = d[6].split("_")[0].to_s
      prezzo = d[5].to_f
      begin
        @totale_diretto[anno] = @totale_diretto[anno] + prezzo
      rescue
        @totale_diretto[anno] = prezzo
      end
    end
  end
  
  @data.each do |d|
    if !d[6].nil? && d[2].start_with?("08")
      anno = d[6].split("_")[0].to_s
      prezzo = d[5].to_f
      begin
        @totale_cottimo[anno] = @totale_cottimo[anno] + prezzo
      rescue
        @totale_cottimo[anno] = prezzo
      end
    end
  end
     
  pp @totale 
  
  @titolo = "#{@scheda["ragione"]} - Dati AntiCorruzione Legge 190/12 art.1 comma 32"

  erb :azienda_190
end
