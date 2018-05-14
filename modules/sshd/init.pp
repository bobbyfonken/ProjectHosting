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
}
