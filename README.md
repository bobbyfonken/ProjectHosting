# ProjectHosting - PHP file server with Puppet
This project contains the documents necessary to configure your Puppetfarm.
This will automate the configuration of file upload with PHP aswell as make the users for the system and the database.

## Preconfiguratie
### DNS
We moeten eerst de namen van onze machines veranderen. Verander de naam van de Puppet master in **"puppet"**. Dit is een verplichtheid. 
De andere mag je kiezen, maar zorg voor een duidelijke naam!
Hieronder vind je een overzicht van de VM's met IP-adres en naam.

| Servername 	| Host-only		| Nat         |
| --------------|:-------------:| -----------:|
| puppet 		    |192.168.137.104 | 10.148.14.8 |
| puppetLamp 	  |192.168.137.105 | 10.148.14.7 |
| puppetDns 	  |192.168.137.106 | 10.148.14.4 |

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
Pas deze file zo aan dat de agent met de master kunnen communiceren.
Puppet: "/etc/hosts"

```
127.0.0.1       localhost
127.0.1.1       puppet
192.168.137.104		puppet
192.168.137.105		puppetLamp	puppetclient
192.168.137.106		puppetDns	puppetclient
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
Je kan voorbeeld inhoud van deze file bovenaan ook vinden.

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
puppetdns.projecthosting.       IN      A       192.168.137.106
puppetlamp.projecthosting.      IN      A       192.168.137.105
puppet.projecthosting.          IN      A       192.168.137.104
```

Bij het bestand hieronder moet men exact zijn, anders werkt het niet! Een template kan men gebruiken via onderstaand commando.  

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

We zullen eerst het volgende commando uitvoeren om met puppet mysql te kunnen installeren. 

**sudo /opt/puppetlabs/bin/puppet module install puppetlabs-mysql**

Vervolgens gaan we onze eigen module maken. Het scheve 'lamp' is de naam van je module. Deze moeten overeenkomen! Dit wordt gevolgd door de map "manifests", met daarna een bestand "init.pp". 

**cd /etc/puppetlabs/code/environments/production/modules**
**sudo mkdir -p /etc/puppetlabs/code/environments/production/modules/_lamp_/manifests**
**sudo mkdir -p /etc/puppetlabs/code/environments/production/modules/_users_/manifests**
**sudo mkdir -p /etc/puppetlabs/code/environments/production/modules/_osticket_/manifests**

Vervolgens ga je in het onderstaande bestand het volgende invullen. Het moet 'init.pp' noemen! 
Pas op met het kopiëren van hieronder! Linux kan hier problemen mee krijgen (spaties/tabs)! 

**sudo nano /etc/puppetlabs/code/environments/production/modules/lamp/manifests/init.pp**

Je zal merken dat erin dit manifest verwezen wordt naar bepaalde "template" bestanden. Zorg dat deze aanwezig zijn (deze zijn in het scheef aangeduid).

```
class lamp { 
#execute 'apt-get update' 
	exec { 'apt-update' : 
	command => '/usr/bin/apt-get update', 
	before => Package['apache2'],
} 

#install apache2 package 
package { 'apache2' : 
	ensure => latest, 
} 

#ensure apache2 service is running 
service { 'apache2' : 
	ensure => running, 
	require => Package['apache2'], 
} 

# install php7 package 
package { 'php7.0' : 
	ensure => latest, 
} 

package { 'libapache2-mod-php7.0' :  
	ensure => latest, 
} 

# ensure info.php file exists 
file { '/var/www/html/info.php': 
	ensure => file, 
	content => '<?php phpinfo(); ?>', 
	require => Package['apache2'], 
} 

# custom apache2 config 
exec { 'a2enmod userdir' : 
	command => '/usr/sbin/a2enmod userdir', 
} 

exec { 'apache2 reload' : 
	command => '/usr/sbin/service apache2 reload', 
} 

file { '/etc/apache2/mods-enabled/php7.0.conf': 
	notify  => Service['apache2'], 
	owner   => 'root', 
	group   => 'root', 
	require => Package['apache2'], 
	content => template('/srv/puppet/files/php7.0.conf'), 
} 

exec { 'apache2 reload 2' : 
	command => '/usr/sbin/service apache2 reload', 
} 

# install phpmyadmin 
package { 'phpmyadmin' : 
	ensure => latest, 
} 
  
package { 'php-mbstring' : 
	ensure => latest, 
} 
  
package { 'php-gettext' : 
	ensure => latest, 
} 

# Comment volgende exec uit van zodra het 1 keer is uitgevoerd en phpmyadmin werkende is! 
exec { 'apache2 phpmyadmin' : 
	command => '/bin/ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf', 
} 

exec { 'apache2 phpmyadmin 2' : 
	command => '/usr/sbin/a2enconf phpmyadmin.conf', 
} 

exec { 'apache2 phpmyadmin reload' : 
	command => '/usr/sbin/service apache2 reload', 
} 

# install vsftpd and configure 
package { 'vsftpd' : 
	ensure => latest, 
} 

#ensure vsftpd service is running 
service { 'vsftpd' : 
	ensure => running, 
	require => Package['vsftpd'], 
} 

#execute 'apt-get update' 
exec { 'apt-update 2' : 
	command => '/usr/bin/apt-get update', 
} 

file { '/etc/vsftpd.conf': 
	notify  => Service['vsftpd'], 
	owner   => 'root', 
	group   => 'root', 
	require => Package['vsftpd'], 
	content => template('/srv/puppet/files/vsftpd.conf'), 
} 

file { '/etc/vsftpd.chroot_list': 
	notify  => Service['vsftpd'], 
	owner   => 'root', 
	group   => 'root', 
	require => Package['vsftpd'], 
	content => template('/srv/puppet/files/vsftpd.chroot_list'), 
}
} 
```

Voeg ook onderstaand manifest toe. Dit doet al wat van instellingen voor osTicket.

```
class osticket {	
	file { '/etc/php/7.0/fpm/php.ini':
        owner   => 'root',
        group   => 'root',
        content => template('/srv/puppet/files/php.ini'),
	}

	# reload php7.0-fpm
	exec { 'php7 reload' :
		command => '/usr/sbin/service php7.0-fpm reload',
	}
	
	# Make directory for osticket
	file { '/var/www/html/osticket':
		ensure => 'directory',
		owner  => 'www-data',
		group  => 'www-data',
		mode   => '0755',
	}
}
```

### Generating system users and mysql users with Python3 

Via onderstaand scriptje kan je op basis van een inputfile met users en wachtwoorden gescheiden door komma's, 
de systeem- en mysquser structuren voor puppet aanmaken. 
Zie hieronder voor voorbeeld structuur voor inputfile.

**bobby;P@ssw0rd**

```
# import neccesary modules
from hashlib import sha1
import sys, os

#### Variabels
# filenames of the inputfile and outputfile
inputFile = "users-Unstructered.csv"
outputFileSystemUsers = "systemusers-done.pp"
outputFileMYsqlUsers = "mysqlusers-done.pp"

#Begin of the uids on the lamp-stack system
uid = 1001

# These are used to store the output for the files
resultSystemUsers = ""
resultMYsqlUsers = ""
mysqluser = ""
mysqldatabase = ""
mysqlgrants = ""

# Open the inputfile
file = open(inputFile, "r")

# begin the structured output for the files
resultSystemUsers += "class users {\n"
mysqluser += "\t\tusers => {"
mysqldatabase += "\t\tdatabases => {"
mysqlgrants += "\t\tgrants => {"

# read every person with password
for line in file:
	fields = line.split(";")
	field1 = fields[0]
	field2 = fields[1]
	# erase the witspaces and tabs
	field1name = "".join(field1.split() )
	field2pass = "".join(field2.split() )

	# First we will generate the users of the system in a file
	resultSystemUsers += "user {{ \"{}\":\n\tensure => present,\n\tpassword => pw_hash(\"{}\", \"SHA-256\", \"mysalt\"),\n\tuid => \"{}\",\n\tshell => \"/bin/bash\",\n\thome => \"/home/{}\",\n\tmanagehome => true,\n}}\n\n".format(field1name, field2pass, uid, field1name)
	uid += 1

	# now we will generate the mysql user txt file to use
	mysql_hash = "*" + sha1(sha1(field2pass.encode("utf-8")).digest()).hexdigest()
	mysqluser += "\n\t\t\t\"{}@localhost\" => {{\n\t\t\t\tensure => \"present\",\n\t\t\t\tmax_connections_per_hour => \"0\",\n\t\t\t\tmax_user_connections => \"0\",\n\t\t\t\tpassword_hash => \"{}\",\n\t\t\t}},\n".format(field1name, mysql_hash)
	mysqldatabase += "\n\t\t\t\"{}\" => {{\n\t\t\t\tensure => \"present\",\n\t\t\t\tcharset => \"utf8\",\n\t\t\t}},\n".format(field1name)
	mysqlgrants += "\n\t\t\t\"{}@localhost/{}.*\" => {{\n\t\t\t\tensure => \"present\",\n\t\t\t\toptions => [\"GRANT\"],\n\t\t\t\tprivileges => [\"ALL\"],\n\t\t\t\ttable => \"{}.*\",\n\t\t\t\tuser => \"{}@localhost\",\n\t\t\t}},".format(field1name, field1name, field1name, field1name)

# Close the structured output
resultSystemUsers += "}"
resultMYsqlUsers += mysqluser + "\n\t\t},\n" + mysqldatabase + "\n\t\t},\n" + mysqlgrants + "\n\t\t},\n"

# write the result for the systemusers to a file in the same directory as where the script runs
fileResultSystemUsers = open(outputFileSystemUsers, "w")
fileResultSystemUsers.write(resultSystemUsers)
fileResultSystemUsers.close()

# write the result for the mysqlusers to a file in the same directory as where the script runs
fileResultMYsqlUsers = open(outputFileMYsqlUsers, "w")
fileResultMYsqlUsers.write(resultMYsqlUsers)
fileResultMYsqlUsers.close()

# Close the inputfile
file.close()

# Print that the files have been generated
print ("The file have been generated!")
```

Bovenaan kan men het nodige python bestand vinden.
Doe dit in een aparte dirrectory!

Bekijk zeer goed de inhoud van de gemaakte files. Zorg dat je begrijpt wat de verschillende opties doen. 
Zo moet je bijvoorbeeld voor het verwijderen van een systeemgebruiken in plaats van "present", "absent" gebruiken. Vergeet dan ook niet de database user te verwijderen. 
De inhoud van file "systemusers-done.pp" kopieer je naar "/etc/puppetlabs/code/environments/production/modules/users/manifests/init.pp". 

**sudo cp ~/systemusers-done.pp /etc/puppetlabs/code/environments/production/modules/users/manifests/init.pp**

Vervolgens verwijs je in het main manifest naar de correcte modules. Hierin komen volgende regels voor. 
("Insert from this line" zal hieronder worden uitgelegd. Dit is voor de mysql users) 

**sudo nano /etc/puppetlabs/code/environments/production/manifests/site.pp**
```
node default {}  

node 'puppetlamp' { 
	include lamp 
	include users  

    class { '::mysql::server': 
        root_password    => 'r0668236',
	remove_default_accounts	=> true,
		**Insert from this line**
	}
}
```

Om de mysqlusers toe te voegen zal je het genereerde bestand moeten toevoegen aan site.pp van het hoofdmanifest bestand. 
De "Insert from this line" lijn is vanaf waar het in te voegen. 
In nano kan je "ctrl + c" gebruiken om jee huidige positie te zien. Deze ga je voor de commando's hieronder moeten gebruiken. 
Zorg ervoor dat je hierbij in de directory van de gegenereerde bestanden staat!

Dit zal de eerste 10 regels van ons huidig site.pp bestand plaatsen in ons nieuw site.pp bestand. 
**sudo head -n 10 /etc/puppetlabs/code/environments/production/manifests/site.pp > site.pp**

 
Dit zal de inhoud van ons genereerd bestand plaatsen in ons nieuw site.pp bestand. 
**sudo cat mysqlusers-done.pp >> site.pp**


Dit zal de regels na regel 10 van ons oorspronkelijk bestand naar ons nieuw site.pp bestand. 
**sudo tail --lines=+10 /etc/puppetlabs/code/environments/production/manifests/site.pp >> site.pp**

Nu moet men nog het oorspronkelijk bestand verwijderen en vervangen door ons nieuw bestand. 
**sudo rm /etc/puppetlabs/code/environments/production/manifests/site.pp**
**sudo cp site.pp /etc/puppetlabs/code/environments/production/manifests/site.pp**

Voeg nu nog onderstaande sql-gebruiker toe in het hoofdmanifest site.pp.
```
"osticket@localhost" => {
				ensure => "present",
				max_connections_per_hour => "0",
				max_user_connections => "0",
				password_hash => "*5BBB23A9A9EB2121530E29594602EC7A69BAA4CF",
			},
			
"osticketdb" => {
				ensure => "present",
				charset => "utf8",
			},
			
"osticket@localhost/osticket.*" => {
				ensure => "present",
				options => ["GRANT"],
				privileges => ["ALL"],
				table => "osticket.*",
				user => "osticket@localhost",
			},
```

Vervolgens kan men op de puppet agent volgende commando uitvoeren.  
Het start de automatische configuratie van je server.
**sudo /opt/puppetlabs/bin/puppet agent -t**

## Postconfiguratie
### VSFTPD
Onderstaand commando genereert voor ons een keypair voor vsftpd, dit moet maar eenmalig.

**sudo openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/vsftpdserverkey.pem -out /etc/ssl/certs/vsftpdcertificate.pem -days 365**

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

# Conclusie
Als alles goed verlopen is, kan je nu via **"http://ip_adres/~username"** zien dat je lamp-stack werkt na toevoegen van een bestand! 
Als men nu via bijvoorbeeld NetBeans fileupload instelt, zal je zien dat het zou moeten werken. Dan ziet de url er voor nu als volgt uit. **http://ip_adres/~username.**.

Men zou ook op phpmyadmin moeten kunnen geraken via **"http://ip_adres/phpmyadmin"**.

Je Puppetfarm zou nu moeten werken! 
