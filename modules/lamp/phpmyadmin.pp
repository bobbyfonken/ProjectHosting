class lamp::phpmyadmin {
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
}
