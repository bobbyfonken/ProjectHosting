class lamp::userdir {
	# custom apache2 config 
	exec { 'a2enmod userdir' : 
		command => '/usr/sbin/a2enmod userdir', 
	}
}
