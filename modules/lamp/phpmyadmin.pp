class lamp::phpmyadmin {
	# install phpmyadmin 
	package { 'phpmyadmin' : 
		ensure => latest, 
	} 
	
	# install phpmyadmin
	package { 'php-mbstring' : 
		ensure => latest, 
	} 
	
	# install phpmyadmin
	package { 'php-gettext' : 
		ensure => latest, 
	} 
	
	# Configuration file for phpmyadmin
	file { '/etc/apache2/conf-available/phpmyadmin.conf': 
		owner   => 'root', 
		group   => 'root', 
		require => Package['phpmyadmin'], 
		content => template('/srv/puppet/files/phpmyadmin.conf'), 
	} 
	
	# activate configuration in apache
	exec { 'apache2 phpmyadmin 2' : 
		command => '/usr/sbin/a2enconf phpmyadmin', 
	} 
	
	# reload apache to enable phpmyadmin
	exec { 'apache2 phpmyadmin reload' : 
		command => '/usr/sbin/service apache2 reload', 
	} 
}
