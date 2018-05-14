class SSHD {
	#install openssh-server package 
	package { 'openssh-server' : 
		ensure => latest, 
	} 
	
	#install ssh package 
	package { 'ssh' : 
		ensure => latest, 
	} 
	
	#Template config file
	file { '/etc/ssh/sshd_config': 
		notify  => Service['openssh-server'], 
		owner   => 'root', 
		group   => 'root', 
		require => Package['openssh-server'], 
		content => template('/srv/puppet/files/sshd_config'), 
	}
}
