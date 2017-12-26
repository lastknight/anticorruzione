require 'rubygems'
require 'json'
require 'date'
require 'pp'

anno = ARGV[0]
anno = 2017 if anno.nil?

file = File.read "./l190-#{anno}.json"
list = JSON.parse(file)

counter = 0

ko = 0
ok = 0

delimiter = "<!-- @@@@@ -->"
testo = ""

template_single = File.read('./data/TEMPLATE_internal.html')

list.each do |k|
  counter += 1
  puts "#{counter} --------------------------------"
  puts ragione = k["ragioneSociale"]
  puts fiscale = k["codiceFiscale"]
  puts pec = k["identificativoPEC"]
  puts url = k["url"]
  puts raw_data = DateTime.parse(k["dataUltimoTentativoAccessoUrl"])
  puts data = "#{raw_data.day}/#{raw_data.month}/#{raw_data.year}"
  puts esito = k["esitoUltimoTentativoAccessoUrl"]
  if esito.include?("fall")
    ko +=1
  elsif esito.include?("succ")
    ok +=1
  end
    
  item = "
  <tr>
      <td><a href='./schede/#{fiscale}-#{anno}.html'>#{ragione}</a></td>
      <td>#{fiscale}</td>
      <td>#{data}</td>
      <td class='text-primary'>#{esito}</td>
      <td><a href='#{url}'>Link</a> - <a href='./schede/#{fiscale}-#{anno}.html'>Scheda</a></td>
  </tr>"
  testo = testo + item
  
  # Rendering singola pagina
  
  single_page = "
  <tr>
      <th width='10%'>Ragione Sociale</th>
      <td>#{ragione}</td>
  </tr>
  <tr>
      <th>Codice Fiscale</th>
      <td>#{fiscale}</td>
  </tr>
  <tr>
      <th>Identificativo PEC</th>
      <td>#{pec}</td>
  </tr>
  <tr>
      <th>Data ultimo tentativo di accesso</th>
      <td>#{raw_data} (#{data})</td>
  </tr>
  <tr>
      <th>Esito ultimo tentativo di accesso</th>
      <td>#{esito}</td>
  </tr>
  <tr>
      <th>Indirizzo</th>
      <td><a href='#{url}'>#{url}</url></td>
  </tr>"
  single_rendered = template_single.gsub(delimiter, single_page).gsub("<!-- ragione -->", ragione.to_s).gsub("<!-- anno -->", anno.to_s)
  File.write("./data/schede/#{fiscale}-#{anno}.html", single_rendered)

  
end

template = File.read('./data/TEMPLATE.html')

rendered = template.gsub(delimiter, testo).gsub("<!-- ok -->", ok.to_s).gsub("<!-- ko -->", ko.to_s).gsub("<!-- total -->", counter.to_s).gsub("<!-- anno -->", anno)

File.write("./data/anticorruzione-#{anno}.html", rendered)

