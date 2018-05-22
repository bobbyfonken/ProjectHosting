class lamp::vsftpd (
	String $port = '',
	String $umask = '',
	String $vsftpdserverkey = '',
	String $vsftpdcertificate = '',
	Array $freeusers = '',
){
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
		notify => Service['vsftpd'],
		owner => 'root',
		group => 'root',
		require => Package['vsftpd'],
		content => epp('/srv/puppet/files/vsftpd.conf.epp',
                {
                        'port' => $port,
			'umask' => $umask,
			'vsftpdserverkey' => $vsftpdserverkey,
			'vsftpdcertificate' => $vsftpdcertificate,
                },
                ),
	} 
	
	# vsftpd chroot list (allowing these users to be free)
	file { '/etc/vsftpd.chroot_list':
		notify => Service['vsftpd'],
		owner => 'root',
		group => 'root',
		require => Package['vsftpd'],
		content => epp('/srv/puppet/files/vsftpd.chroot_list.epp',
                {
                        'freeusers' => $freeusers,
                },
                ),
	}

	# reload vsftpd to activate configuration
	exec { 'vsftpd reload' :
		command => '/usr/sbin/service vsftpd reload',
	}
}
