require 'sinatra'
require 'sinatra/contrib'
require "sinatra/reloader" if development?
require 'redis'

$r = Redis.new

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
  @titolo = "#{@scheda['ragione']} - Dati AntiCorruzione Legge 190/12 art.1 comma 32 - Anno #{anno}"
  erb :scheda_190
end
