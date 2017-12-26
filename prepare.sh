wget http://dati.anticorruzione.it/data/l190-2017.json
wget http://dati.anticorruzione.it/data/l190-2016.json
wget http://dati.anticorruzione.it/data/l190-2015.json
ruby warmup.rb 2017
ruby warmup.rb 2016
ruby warmup.rb 2015