class lamp::userdir {
	# enable to use users home directory ~/public_html for apache
	exec { 'a2enmod userdir' : 
		command => '/usr/sbin/a2enmod userdir', 
	}
	
	# enable the use of PHP in that directory
	file { '/etc/apache2/mods-available/php7.0.conf': 
		notify  => Service['apache2'], 
		owner   => 'root', 
		group   => 'root', 
		require => Package['apache2'], 
		content => template('/srv/puppet/files/php7.0.conf'), 
	} 

	# enable the configuration
	exec { 'a2enmod php7.0' :
		command => '/usr/sbin/a2enmod php7.0',
	}
	
	# reload apache to activate changes
	exec { 'apache reload 3' : 
		command => '/usr/sbin/service apache2 reload', 
	}
}
