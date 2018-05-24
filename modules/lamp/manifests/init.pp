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
	
	Package { 'php7.0-mysql' :
                ensure => latest,
        }
	
	package { 'libapache2-mod-php7.0' :  
		ensure => latest, 
	} 
	
	# Securing apache: hide sensitive information
	file { '/etc/apache2/conf-available/custom.conf':
		notify  => Service['apache2'],
		owner   => 'root',
		group   => 'root',
		require => Package['apache2'],
		content => template('/srv/puppet/files/custom.conf'),
	}

	# Securing apache: hide sensitive information
	exec { 'a2enmod headers' :
		command => '/usr/sbin/a2enmod headers',
	}

	# Securing apache: hide sensitive information
	exec { 'a2enconf custom.conf' :
		command => '/usr/sbin/a2enconf custom',
		subscribe => File['/etc/apache2/conf-available/custom.conf'],
	} 
	
	# Securing apache: Protect from DoS
	package { 'libapache2-mod-evasive' :  
		ensure => latest, 
	} 
	
	# Securing apache: Protect from DoS
	file { '/etc/apache2/mods-available/evasive.conf': 
		notify  => Service['apache2'], 
		owner   => 'root', 
		group   => 'root', 
		require => Package['apache2'], 
		content => template('/srv/puppet/files/evasive.conf'), 
	} 
	
	# Securing apache: Protect from DoS
	exec { 'a2enmod evasive' :
		command => '/usr/sbin/a2enmod evasive',
	}
	
	# Securing apache: Protect from DoS
	# Make directory for evasive log files
	file { '/var/log/mod_evasive':
		ensure => 'directory',
		owner  => 'root',
		group  => 'www-data',
		mode   => '0750',
	}
	
	# reload apache to make the configuration active
	exec { 'apache reload' : 
		command => '/usr/sbin/service apache2 reload', 
	}
} 
