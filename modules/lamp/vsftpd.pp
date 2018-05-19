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

	exec { 'vsftpd reload' : 
		command => '/usr/sbin/service vsftpd reload', 
	}
}
