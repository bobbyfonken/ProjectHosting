# Manifesten met puppet
Vervolgens verwijs je in het main manifest naar de correcte modules. Hierin komen volgende regels voor. 
("Insert from this line" zal hieronder worden uitgelegd. Dit is voor de mysql users en  "Public key here" is voor ssh-rsa (Deze zijn hier gezet zodat je er verschillende gebruikt per node!)) 

**sudo nano /etc/puppetlabs/code/environments/production/manifests/site.pp**
