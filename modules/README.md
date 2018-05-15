Hierboven staan de verschillende modules die ik zelf heb gemaakt.

We zullen eerst het volgende commando uitvoeren om met puppet mysql te kunnen installeren. 

**sudo /opt/puppetlabs/bin/puppet module install puppetlabs-mysql**

Vervolgens gaan we onze eigen module maken. Het scheve 'lamp' is de naam van je module. Deze moeten overeenkomen! Dit wordt gevolgd door de map "manifests", met daarna een bestand "init.pp". 

**cd /etc/puppetlabs/code/environments/production/modules**
**sudo mkdir -p /etc/puppetlabs/code/environments/production/modules/_lamp_/manifests**
**sudo mkdir -p /etc/puppetlabs/code/environments/production/modules/_users_/manifests**
**sudo mkdir -p /etc/puppetlabs/code/environments/production/modules/_osticket_/manifests**
**sudo mkdir -p /etc/puppetlabs/code/environments/production/modules/_database_/manifests**
**sudo mkdir -p /etc/puppetlabs/code/environments/production/modules/_sshd_/manifests**

Vervolgens ga je in het onderstaande bestand het volgende invullen. Het moet 'init.pp' noemen! 
Pas op met het kopiëren van hieronder! Linux kan hier problemen mee krijgen (spaties/tabs)! 

**sudo nano /etc/puppetlabs/code/environments/production/modules/lamp/manifests/init.pp**

Je zal merken dat erin dit manifest verwezen wordt naar bepaalde "template" bestanden. Zorg dat deze aanwezig zijn! Bij mij staan ze op de puppet master onder **"/srv/puppet/files/"**.

Andere manifesten van de verschillende modules vind je hierboven terug. Deze zijn op een gelijkaardige manier gemaakt.
