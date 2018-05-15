class sshd {
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
		owner   => 'root', 
		group   => 'root', 
		content => template('/srv/puppet/files/sshd_config'), 
	}
	
	#ensure ssh service is running
	service { 'ssh' :
	ensure => running,
		require => Package['openssh-server'],
	}

	#Restart ssh service
	exec { 'ssh reload' :
		command => '/usr/sbin/service ssh reload',
	}
}
