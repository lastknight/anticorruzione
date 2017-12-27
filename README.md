# Una analisi visuale dei DataSet AntiCorruzione

## Perché questo progetto

Quale adempimento alla Legge 190/2012 art. 1, comma 32 le *Stazioni Appaltanti (SA)* della Pubblica Amministrazione sono obbligate alla pubblicazione dei dati in formato aperto, ai sensi dell’art. 1 comma 32 Legge 190/2012 conforme alle disposizioni di cui alla Deliberazione n. 39 del 2 gennaio 2016. A tale fine devono:

* Trasmettere all’Autorità, entro il 31 gennaio di ogni anno, solo mediante Posta Elettronica Certificata all'indirizzo comunicazioni@pec.anticorruzione.it, un messaggio di PEC attestante l’avvenuto adempimento. Tale messaggio PEC deve riportare obbligatoriamente, nell’apposito modulo PDF (si deve utilizzare esclusivamente la versione del modulo aggiornata al 15 gennaio 2016), il codice fiscale della Stazione Appaltante e l’URL di pubblicazione del file XML per l’anno  in corso. I messaggi PEC ricevuti attraverso canali diversi dalla PEC dedicata comunicazioni@pec.anticorruzione.it , compresi quelli ricevuti attraverso la casella protocollo@pec.anticorruzione.it , non saranno considerati validi ai fini dell’assolvimento degli obblighi previsti dalla norma e non saranno elaborate. Inoltre, si ricorda che l’indirizzo PEC comunicazioni@pec.anticorruzione.it dovrà essere utilizzato esclusivamente per gli adempimenti di cui all’art.1 comma 32 della legge 190/2012.
* Pubblicare sul proprio sito web istituzionale le informazioni di cui all’articolo 4 della Deliberazione n.39 del 2 gennaio 2016 secondo la struttura e le modalità definite dall’Autorità (vedi specifiche tecniche aggiornate per la pubblicazione dei dati in file XML).

Ora tali dati "vivono" all'[interno delle pagine apposite dell'ANAC](http://dati.anticorruzione.it/#/l190) ma sono di difficile consultazione e soprattutto una buona quantità di queste (circa 1/3) non sono raggiungibili.  
  
I dati contenuti sono però di massima importanza e questo progetto nasce con il triplice fine di:

* Consentire una agevole indicizzazione dei contenuti di tali comunicazioni e la facile "navigazione";
* Sensibilizzare le realtà che non sono a norma nella pubblicazione dei dati e nella correzione delle problematiche;
* Analizzare i dataset correlati in modo agevole e comodo, per una maggiore trasparenza; 

Per qualunque informazione aggiuntiva è possibile richiedere informazioni all'[Hermes Center](http://hermescenter.org)

## Come funziona

In linea di massima il sistema è legato a tre differenti componenti principali:

* Una serie di script (`prepare.sh`, `warmup.rb`, `archive.rb`, etc...) che servono per popolare la base dati da utilizzare;
* Un database Redis che contiene i dati (semi) strutturati e serve per la creazione delle pagine;
* Una applicazione Ruby Sinatra per la visualizzazione dei dati contenuti nella istanza di Redis

Il dettaglio delle singole componenti:

* `prepare.sh` scarica i file XML direttamente da ANAC per popolare gli elenchi dei differenti anni e invoca gli altri script;
* `warmup.rb ANNO` esegue l'importazione in Redis dell'anno corrispondente
* `archive.rb ANNO` scarica dai differenti siti web gli XML per l'archivio locale, scaricando eventualmente anche i documenti "correlati" come linkDataset;
* `app.rb` è invece l'applicazione Sinatra;

Per quanto concerne le directory:

* `views` contiene i template dell'applicazione Sinatra;
* `public` contiene stili & co relativi al template utilizzato;
* `data_storage` contiene la cache locale dei file *[e può essere cancellata per ricrearla]*;


## Installazione

Consigliato per la visualizzazione l'installazione di Ruby >2.2.2. E' necessario avere installato (e funzionante) Redis per rendere usabile il sistema.
  
Le manovre per l'installazione sono relativamente semplici:

1. Eseguire `redis-server` con le opzioni di default;
1. Da un differente `screen` o console in genere installare le dipendenze con `bundle install`
1. Una volta che tutto è installato a dovere e non vi sono messaggi di errore eseguire il warm-up con `sh prepare.sh`
1. Se tutto procede tranquillamente eseguire la app con `ruby app.rb -p 9090`
1. Puntare il proprio browser a `http://127.0.0.1:9090` e vedere la magia che prende forma :D
