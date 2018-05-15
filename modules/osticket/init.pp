class osticket {	
	file { '/etc/php/7.0/fpm/php.ini':
		owner   => 'root',
		group   => 'root',
		content => template('/srv/puppet/files/php.ini'),
	}

	# reload php7.0-fpm
	exec { 'php7 reload' :
		command => '/usr/sbin/service php7.0-fpm reload',
	}
	
	# Make directory for osticket
	file { '/var/www/html/osticket':
		ensure => 'directory',
		owner  => 'www-data',
		group  => 'www-data',
		mode   => '0755',
	}
}
