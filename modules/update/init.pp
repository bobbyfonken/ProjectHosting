class update {
	#execute 'apt-get update' 
		exec { 'apt-update' : 
		command => '/usr/bin/apt-get update', 
	} 
	
	#execute 'apt-get upgrade'
		exec { 'apt-upgrade' :
		command => '/usr/bin/apt-get upgrade -y',
	}
}
