class lamp::userdir {
	# custom apache2 config 
	exec { 'a2enmod userdir' : 
		command => '/usr/sbin/a2enmod userdir', 
	}
	
	file { '/etc/apache2/mods-available/php7.0.conf': 
		notify  => Service['apache2'], 
		owner   => 'root', 
		group   => 'root', 
		require => Package['apache2'], 
		content => template('/srv/puppet/files/php7.0.conf'), 
	} 

	exec { 'a2enmod php7.0' :
		command => '/usr/sbin/a2enmod php7.0',
	}
	
	exec { 'apache reload 3' : 
		command => '/usr/sbin/service apache2 reload', 
	}
}
