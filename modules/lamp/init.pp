class lamp { 
	#execute 'apt-get update' 
		exec { 'apt-update' : 
		command => '/usr/bin/apt-get update', 
		before => Package['apache2'],
	} 
	
	#execute 'apt-get upgrade'
		exec { 'apt-upgrade' :
		command => '/usr/bin/apt-get upgrade -y',
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
