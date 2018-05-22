class lamp::vsftpd {
	# install vsftpd and configure 
	package { 'vsftpd' : 
		ensure => latest, 
	} 
	
	#ensure vsftpd service is running 
	service { 'vsftpd' : 
		ensure => running, 
		require => Package['vsftpd'], 
	} 
	
	# vsftpd configuration
	file { '/etc/vsftpd.conf': 
		notify  => Service['vsftpd'], 
		owner   => 'root', 
		group   => 'root', 
		require => Package['vsftpd'], 
		content => template('/srv/puppet/files/vsftpd.conf'), 
	} 
	
	# vsftpd chroot list (allowing these users to be free)
	file { '/etc/vsftpd.chroot_list': 
		notify  => Service['vsftpd'], 
		owner   => 'root', 
		group   => 'root', 
		require => Package['vsftpd'], 
		content => template('/srv/puppet/files/vsftpd.chroot_list'), 
	}

	# reload vsftpd to activate configuration
	exec { 'vsftpd reload' : 
		command => '/usr/sbin/service vsftpd reload', 
	}
}
