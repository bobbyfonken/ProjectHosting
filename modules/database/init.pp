class database {
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
	
	# file to hide sensitive information
        file { '/etc/apache2/conf-available/custom.conf':
                notify  => Service['apache2'],
                owner   => 'root',
                group   => 'root',
                require => Package['apache2'],
                content => template('/srv/puppet/files/custom.conf'),
        }

       # custom apache2 config 2
        exec { 'a2enmod headers' :
                command => '/usr/sbin/a2enmod headers',
        }

       # custom apache2 config 3
        exec { 'a2enconf custom.conf' :
                command => '/usr/sbin/a2enconf custom.conf',
        }
	
	exec { 'apache2 reload' : 
		command => '/usr/sbin/service apache2 reload', 
	} 
	
	# install phpmyadmin 
	package { 'phpmyadmin' : 
		ensure => latest, 
	} 
	
	package { 'php-mbstring' : 
		ensure => latest, 
	} 
	
	package { 'php-gettext' : 
		ensure => latest, 
	} 
	
	# Comment volgende exec uit van zodra het 1 keer is uitgevoerd en phpmyadmin werkende is! 
	exec { 'apache2 phpmyadmin' : 
		command => '/bin/ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf', 
	} 
	
	exec { 'apache2 phpmyadmin 2' : 
		command => '/usr/sbin/a2enconf phpmyadmin.conf', 
	} 
	
	exec { 'apache2 phpmyadmin reload' : 
		command => '/usr/sbin/service apache2 reload', 
	} 
}
