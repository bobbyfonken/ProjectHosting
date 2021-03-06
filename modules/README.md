# Modules with puppet

Hierboven staan de verschillende modules die ik zelf heb gemaakt.

We zullen eerst volgende commando's uitvoeren om puppet modules toe te voegen, die ons o.a. toelaat om mysql te kunnen installeren en configureren met puppet. 

**sudo /opt/puppetlabs/bin/puppet module install puppetlabs-mysql**

**sudo /opt/puppetlabs/bin/puppet module install puppetlabs-stdlib --version 4.25.1**

**sudo /opt/puppetlabs/bin/puppet module install dhoppe-fail2ban --version 1.3.5**

**sudo /opt/puppetlabs/bin/puppet module install puppetlabs-firewall --version 1.12.0**

Vervolgens gaan we onze eigen module maken. Het scheve 'lamp' is de naam van je module. Deze moeten overeenkomen! Dit wordt gevolgd door de map "manifests", met daarna een bestand "init.pp" om mee te beginnen. 

**cd /etc/puppetlabs/code/environments/production/modules**

**sudo mkdir -p /etc/puppetlabs/code/environments/production/modules/_lamp_/manifests**

Vervolgens maak je onder de **"manifests"** map voor elke module een init.pp bestand en gebruik je de inhoud van bovenstaande modules.
Pas op met het kopiëren! Linux kan hier problemen mee krijgen (spaties vs tabs)! 

**sudo nano /etc/puppetlabs/code/environments/production/modules/lamp/manifests/init.pp**

Je zal merken dat erin de manifesten verwezen wordt naar bepaalde "template" bestanden. Zorg dat deze aanwezig zijn! Bij mij staan ze op de puppet master onder **"/srv/puppet/files/"**. Bekijk deze bestanden, het kan zijn dat je hierin informatie zoals wachtwoorden moet veranderen.

Andere manifesten van de verschillende modules vind je hierboven terug. Deze zijn op een gelijkaardige manier gemaakt.
Let wel op bij de sshd module, deze heeft nog een tweede manifest. In het sshd module init.pp bestand staat de "class sshd". Het manifest users.pp heeft de "class sshd::users". Deze volgen op elkaar. De naam van het bestand is hetzelfde als de naam van de deelklassen: "class sshd::_users_".
