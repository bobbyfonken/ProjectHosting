class lamp { 	
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
	
	# file to hide sensitive information
	file { '/etc/apache2/conf-available/custom.conf':
		notify  => Service['apache2'],
		owner   => 'root',
		group   => 'root',
		require => Package['apache2'],
		content => template('/srv/puppet/files/custom.conf'),
	}

	# custom apache2 config 2
	exec { 'a2enmod headers' :
		command => '/usr/sbin/a2enmod headers',
	}

	# custom apache2 config 3
	exec { 'a2enconf custom.conf' :
		command => '/usr/sbin/a2enconf custom',
	} 
	
	# custom apache2 config 4
	package { 'libapache2-mod-evasive' :  
		ensure => latest, 
	} 
	
	file { '/etc/apache2/mods-available/evasive.conf': 
		notify  => Service['apache2'], 
		owner   => 'root', 
		group   => 'root', 
		require => Package['apache2'], 
		content => template('/srv/puppet/files/evasive.conf'), 
	} 
	
	exec { 'a2enmod evasive' :
		command => '/usr/sbin/a2enmod evasive',
	}
	
	# Make directory for evasive log files
	file { '/var/log/mod_evasive':
		ensure => 'directory',
		owner  => 'root',
		group  => 'www-data',
		mode   => '0750',
	}
	
	exec { 'apache reload' : 
		command => '/usr/sbin/service apache2 reload', 
	}
} 
