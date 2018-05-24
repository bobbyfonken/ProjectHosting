# ProjectHosting - PHP file server with Puppet
This project contains the documents necessary to configure your Puppetfarm.
This will automate the configuration of file upload with PHP aswell as make the users for the system and the database.

## inhoud
 * [ProjectHosting](#projecthosting---php-file-server-with-puppet)
      * [Preconfiguratie](#preconfiguratie)
         * [DNS](#dns)
         * [NTP](#ntp)
      * [Puppet installatie](#puppet-installatie)
         * [Puppet master](#puppet-master)
         * [Puppet agent](#puppet-agent)
         * [Puppet certificaten](#puppet-certificaten)
         * [Puppet manifesten/modules](#puppet-manifestenmodules)
      * [Puppet LAMP-stack](#puppet-lamp-stack)
         * [Generating system users and mysql users with Python3](#generating-system-users-and-mysql-users-with-python3)
      * [Postconfiguratie](#postconfiguratie)
         * [VSFTPD](#vsftpd)
         * [phpmyadmin](#phpmyadmin)
         * [osTicket](#osticket)
   * [Conclusie](#conclusie)
## Extra
Via het commando wget kan je eventueel bestanden van github halen

**wget https://raw.githubusercontent.com/bobbyfonken/ProjectHosting/master/README.md**

git clone kan je het geheel downloaden

**git clone https://github.com/bobbyfonken/ProjectHosting.git**

## Preconfiguratie
Zorg alvorens te beginnen ervoor dat je een update en upgrade hebt uitgevoerd.

### DNS
We moeten eerst de namen van onze machines veranderen. Verander de naam van de Puppet master in **"puppet"**. Dit is een verplichtheid. 
De andere mag je kiezen, maar zorg voor een duidelijke naam!
Hieronder vind je een overzicht van de VM's met IP-adres en naam.

| Servername 		| Host-only		 | Nat         |
|-------------------|:--------------:|------------:|
| puppet 		|172.27.66.70 | 10.148.14.8 |
| puppetLamp 		|172.27.66.73 | 10.148.14.7 |
| puppetDns 		|172.27.66.71 | 10.148.14.4 |
| puppetDatabase 	|172.27.66.72 | 10.148.14.1 |

We zetten eerst de netwerkconfiguratie goed. Doe dit voor elke VM zoals hieronder. 
Veranderen het "address" naar het adres van jouw machine. 
Het "dns-nameservers" richt je naar je dns-server in je netwerk.

```
auto enp0s3**
iface enp0s3 inet static
address 192.168.137.106
netmask 255.255.255.0
network 192.168.137.0
gateway 192.168.137.1
dns-nameservers 192.168.137.106
```

Vervolgens zullen we de namen van de machines veranderen in de volgende file.

**"/etc/hostname"**

Daarna zullen we op elke machine de **"/etc/hosts"** file aanpassen zodat puppet master en agent later met elkaar kunnen communiceren.
Pas deze file zo aan dat de agent met de master kunnen communiceren of andersom.
Puppet: "/etc/hosts"

```
127.0.0.1       localhost
127.0.1.1       puppet
192.168.137.104		puppet
192.168.137.105		puppetLamp	puppetclient
192.168.137.106		puppetDns	puppetclient
192.168.137.107		puppetDatabase	puppetclient
```

Vervolgens passen we de file **"/etc/resolvconf/resolv.conf.d/base"** aan. We doen dit door zoals hieronder aangeven. Vervang het adres door jouw dns-server. 

**nameserver 192.168.137.106**

Bij de dns-server zet je beter er nog **"nameserver 8.8.8.8"** bij, dan kan je alvast bind9 en dnsutils installeren. 
Je moet die regel er na installatie wel terug uit doen en je server herstarten.

Controleer na een reboot in het bestand **"/etc/resolv.conf"** of jouw DNS-server als DNS-server wordt aangenomen.
Deze zou dan bovenaan moeten staan.
Je kan dit testen met een nslookup. Jouw dns-server zou dan tevoorschijn moeten komen.

Nu gaan we een forward lookup zone configureren met bind9. Hiervoor configureren we volgende bestanden.
**"/etc/bind/named.conf.local"**
Je kan voorbeeld inhoud van deze file bovenaan vinden.

```
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     puppetdns.projecthosting. root.projecthosting. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
; name servers - NS records
        IN      NS      puppetdns.projecthosting.
        IN      A       192.168.137.106
        IN      AAAA    ::1
; name servers - A records
puppetDatabase.projecthosting.	IN		A		192.168.137.107
puppetdns.projecthosting.       IN      A       192.168.137.106
puppetlamp.projecthosting.      IN      A       192.168.137.105
puppet.projecthosting.          IN      A       192.168.137.104
```

Bij het bestand hieronder moet men exact zijn, anders werkt het niet! Een template kan men gebruiken via onderstaand commando.

**sudo mkdir /etc/bind/zones**

**sudo cp /etc/bind/db.local /etc/bind/zones/projecthosting**

Een voorbeeld configuratie zie je bovenaan.
De A-records zijn de servers en hun IP-adressen.
Als alles juist is ingesteld, herstart bind9 en een nslookup naar één van de namen zou moeten lukken.

### NTP
Op beide systemen (zowel puppet master als agent) installeren we NTP (Network Time Protocol).  

De tijd moet nauwkeurig ingesteld worden op de puppetmaster die als certificaat-autoriteit optreedt 
om de certificaten afkomstig van de clientsystemen te ondertekenen. 
We zullen hiervoor gebruik maken van NTP. 

We installeren het NTP-pakket en voeren vervolgens een tijdsynchronisatie uit met andere NTP-servers: 

**sudo apt-get install ntp ntpdate**

**sudo ntpdate -u 0.ubuntu.pool.ntp.org**

Lijst de beschikbare tijdzones op en set deze naar één van die zones:  

**timedatectl list-timezones**

**sudo timedatectl set-timezone Europe/Brussels**

Met het commando **"date"** kan men nazien of de tijd van de servers hetzelfde is.

## Puppet installatie
Om de puppet master en de puppet agent te installeren, dienen we de puppet repository ter beschikking te stellen voor alle nodes.  

We gaan hiervoor naar de PuppetLabs repository rpm en installeren deze repository.  
Dit doen we als volgt: Ik heb dit op elke machine uitgevoerd. 

**wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb**

**sudo dpkg -i puppetlabs-release-pc1-xenial.deb**

**sudo apt-get update**

### Puppet master
Vervolgens installeren we puppet op de puppet master VM. 

**sudo apt-get install -y puppetserver**

We starten deze service nog **NIET**! Voordat we dit doen moeten we eerst zien hoeveel RAM onze puppetserver nodig heeft, dit zal afhangen van wat je ter beschikking hebt. Via volgende file kan men dit aanpassen. 

**sudo nano /etc/default/puppetserver**

Pas de waarde aan als volgt:  

From

**JAVA_ARGS="-Xms2g -Xmx2g**

To
Voor 512MB, gebruik de onderstaande instellingen.

**JAVA_ARGS="-Xms512m -Xmx512m"**

Vervolgens ga je in onderstaande locatie nog wat aanpassen zodat puppet naar onze wensen werkt. 

**sudo nano /etc/puppetlabs/puppet/puppet.conf**

Vanaf de regel van codedir moet je de regels toevoegen.

```
dns_alt_names = puppet

[main]
certname = puppet
server = puppet
environment = production
runinterval = 1h
```

Nu kunnen we puppetserver starten. Dit kan even duren. 

**sudo systemctl start puppetserver**

**sudo systemctl enable puppetserver**

### Puppet agent
Vervolgens zullen we de puppet agent installeren. 

**sudo apt-get install -y puppet-agent**

Hier moeten we ook eerst puppet configureren. 

**sudo nano /etc/puppetlabs/puppet/puppet.conf**
```
[main]
certname = puppetlamp
server = puppet
environment = production
runinterval = 1h
```

Zorg ervoor dat de certname etc. lower case is.
Nu kunnen we puppet agent opzetten.

**sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true**

### Puppet certificaten
Vervolgens zullen we de certificaten ondertekenen. 
Als men alle certificaten wilt bezien, kan men volgend commando gebruiken. Voor nu zie je enkel het certificaat van de master. 

**sudo /opt/puppetlabs/bin/puppet cert list -all**

De certificaten met een "+" voor zijn al ondertekend. Zo zie je dat de master al automatisch is getekend. 
Om een certificaat te ondertekenen, kan je het cert sign commando uitvoeren:  

**sudo /opt/puppetlabs/bin/puppet cert sign puppetlamp**

Om een certificate te revoken gebruikt men volgend commando. 

**sudo /opt/puppetlabs/bin/puppet cert clean hostname**

### Puppet manifesten/modules
De master is nu aan het werken. Al heeft deze nog geen agents om te controleren. Dit doen we in de volgende stappen. Ga naar je cliënts zoals de puppetLamp VM. 

Nu kunnen we configuraties doorsturen via manifesten! Je infrastructuur is klaar om te gebruiken! 
Test nu eerst of de verbinding werkt. 

De manifests worden opgeslagen in de directory: "/etc/puppetlabs/code/environments/production/manifests/". 
We zullen eerst een kleine test doen om te zien of onze puppefarm al goed werkt. 

**sudo nano /etc/puppetlabs/code/environments/production/manifests/site.pp**
```
file {'/tmp/example-ip': 
	ensure => present, 
	mode    => "0640", 
	content => "Here is my Public IP Address: ${ipaddress_enp0s8}.\n",
}
```

Voer nu op de agent het volgende  commado uit: 

**sudo /opt/puppetlabs/bin/puppet agent -t**

Als dit goed verloopt, kan je na "sudo cat /tmp/example-ip" doen op de agent. Je zou het ip adres van addapter 1 moeten zien.

## Puppet LAMP-stack
Nu gaan we een lamp-stack installeren doormiddel van puppet. We maken eerst op de puppet master de nodige mappen. Geïnstalleerde of gecreëerde modules komen in volgende directory te staan. 

**/etc/puppetlabs/code/environments/production/modules**

De mappenstructuur hierin wordt in de directory **"modules"** uitgelegd. Bekijk dit eerst!

### Generating system users and mysql users with Python3 

Via het scriptje "gen-users sql-shell.py", kan je op basis van een inputfile met users en wachtwoorden gescheiden door komma's, 
de systeem- en mysquser structuren voor puppet aanmaken. 
Zie hieronder voor voorbeeld structuur voor inputfile. 
In de python file waar het ip-adres '192.168.137.105' staat, vervang dit door het ip-adres van de server waar de files worden geupload.
Voer het python bestand uit met commando 

**"python3 file.py"**.

**bobby;P@ssw0rd**

Bovenaan kan men het nodige python bestand vinden.
Doe dit in een aparte dirrectory!

Bekijk zeer goed de inhoud van de gemaakte files. Zorg dat je begrijpt wat de verschillende opties doen. 
Zo moet je bijvoorbeeld voor het verwijderen van een systeemgebruiken in plaats van "present", "absent" gebruiken. Vergeet dan ook niet de database user te verwijderen. Daarbij moet men zowel "user" als "grant" op absent zetten anders krijgt men een foutmelding van failed dependencies.
De inhoud van file "systemusers-done.pp" kopieer je naar "/etc/puppetlabs/code/environments/production/modules/users/manifests/init.pp". 

**sudo cp ~/systemusers-done.pp /etc/puppetlabs/code/environments/production/modules/users/manifests/init.pp**

Vervolgens verwijs je in het manifest puppetdatabase.pp naar de correcte modules. Hierin komen volgende regel voor:
"Insert from this line". Dit is de lijn waar men de mysql users moet zetten.

**sudo nano /etc/puppetlabs/code/environments/production/manifests/puppetdatabase.pp**

Om de mysqlusers toe te voegen zal je het genereerde bestand moeten toevoegen aan puppetdatabase.pp manifest bestand. 
De "Insert from this line" lijn is vanaf waar het in te voegen. 
In nano kan je "ctrl + c" gebruiken om jee huidige positie te zien. Deze ga je voor de commando's hieronder moeten gebruiken. 
Zorg ervoor dat je hierbij in de directory van de gegenereerde bestanden staat!

Dit zal de eerste 10 regels van ons huidig (bovenstaand) site.pp bestand plaatsen in ons nieuw puppetdatabase.pp bestand. 

**sudo head -n 10 /etc/puppetlabs/code/environments/production/manifests/puppetdatabase.pp > puppetdatabase.pp**
 
Dit zal de inhoud van ons genereerd bestand plaatsen in ons nieuw site.pp bestand. 

**sudo cat mysqlusers-done.pp >> puppetdatabase.pp**

Dit zal de regels na regel 10 van ons oorspronkelijk bestand naar ons nieuw site.pp bestand. 

**sudo tail --lines=+10 /etc/puppetlabs/code/environments/production/manifests/puppetdatabase.pp >> puppetdatabase.pp**

Nu moet men nog het oorspronkelijk bestand verwijderen en vervangen door ons nieuw bestand. 

**sudo rm /etc/puppetlabs/code/environments/production/manifests/puppetdatabase.pp**

**sudo cp puppetdatabase.pp /etc/puppetlabs/code/environments/production/manifests/puppetdatabase.pp**

Voeg nu nog onderstaande sql-gebruiker toe in het manifest puppetdatabase.pp.
```
Onder Users:
"osticket@192.168.137.105" => {
				ensure => "present",
				max_connections_per_hour => "0",
				max_user_connections => "0",
				password_hash => "password hash here",
},
			
"osticket@localhost" => {
				ensure => "present",
				max_connections_per_hour => "0",
				max_user_connections => "0",
				password_hash => "password hash here",
},

"pma@localhost" => {
				ensure => "present",
				max_connections_per_hour => "0",
				max_user_connections => "0",
				password_hash => "password hash here",
},

			
Onder Database:
"osticket" => {
				ensure => "present",
				charset => "utf8",
},

"phpmyadmin" => {
				ensure => "present",
				charset => "utf8",
},


Onder Grants:
"osticket@192.168.137.105/osticket.*" => {
				ensure => "present",
				options => ["GRANT"],
				privileges => ["ALL"],
				table => "osticket.*",
				user => "osticket@192.168.137.105",
			},
			
"osticket@localhost/osticket.*" => {
				ensure => "present",
				options => ["GRANT"],
				privileges => ["ALL"],
				table => "osticket.*",
				user => "osticket@localhost",
			},

"pma@localhost/phpmyadmin.*" => {
				ensure => "present",
				options => ["GRANT"],
				privileges => ["ALL"],
				table => "phpmyadmin.*",
				user => "pma@localhost",
},
```

Vervolgens kan men op de puppet agent volgende commando uitvoeren.  
Het start de automatische configuratie van je server.

**sudo /opt/puppetlabs/bin/puppet agent -t**

Voor het manueel genereren van een mysql password hash, kan je inloggen op de database via de command line.

**sudo mysql -u root -p**

Vervolgens kan je volgend commando uitvoeren om een wachtwoord te veranderen in een password hash die te gebruiken is in het puppet manifest.

**SELECT PASSWORD('MYPASSWORD');**

## Postconfiguratie
### VSFTPD
Onderstaand commando genereert voor ons een keypair voor vsftpd, dit moet maar eenmalig.

**sudo openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/vsftpdserverkey.pem -out /etc/ssl/certs/vsftpdcertificate.pem -days 365**

### phpmyadmin
Log in als de pma user. Wachtwoord heb je normaal ingesteld in het puppetdatabase.pp manifest. Volg de instructies die in het rood vandonder staan.

### osTicket
Om osTicket correct te installeren, volg je onderstaande stappen.

**cd /var/www/html/osticket**

**sudo wget http://osticket.com/sites/default/files/download/osTicket-v1.10.zip**

Zodra het downloaden is gedaan, ga je het bestand uitpakken. Installeer eerst eventueel unzip (**sudo apt-get install unzip**).

**sudo unzip osTicket-v1.10.zip**

Vervolgens kopiër je de sample config file.

**sudo cp upload/include/ost-sampleconfig.php upload/include/ost-config.php**

Verander daarna de eigenaar van alle osticket bestanden en mappen naar "www-data" (zowel user als group).

**sudo chown -R www-data:www-data /var/www/html/osticket**

Nu is het tijd om alles via de webinterface te configureren. Surf naar volgende link.

**http://your-domain.com/osticket/upload/setup/install.php**

Volg de installatie instructies aandachtig. Na installatie verwijder je nog de setup directory en verander je de permissies van osTicket config file.

**sudo rm -rf /var/www/html/osticket/upload/setup**

**sudo chmod 0644 /var/www/html/osticket/include/ost-config.php**

Nu zou osTicket werkende moeten zijn!
Het admin panel kan men normaal hier vinden: **"http://your-domain.com/osticket/upload/scp/settings.php"**.
Een nieuw ticket openen doet men via deze link: **"http://your-domain.com/osticket/upload/"**.

# Conclusie
Als alles goed verlopen is, kan je nu via **"http://ip_adres/~username"** zien dat je lamp-stack werkt na toevoegen van een bestand! 
Als men nu via bijvoorbeeld NetBeans fileupload instelt, zal je zien dat het zou moeten werken. Dan ziet de url er voor nu als volgt uit. **http://ip_adres/~username.**.

Men zou ook op phpmyadmin moeten kunnen geraken via **"http://ip_adres/phpmyadmin"**.

Je Puppetfarm zou nu moeten werken! 
