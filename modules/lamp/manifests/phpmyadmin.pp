class lamp::phpmyadmin 
(
String $controluser = '',
String $controlpass = '',
String $pmadb = '',
){
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
	
	file { '/etc/apache2/conf-available/phpmyadmin.conf': 
		owner   => 'root', 
		group   => 'root', 
		require => Package['phpmyadmin'], 
		content => template('/srv/puppet/files/phpmyadmin.conf'), 
	} 
	
	exec { 'apache2 phpmyadmin 2' : 
		command => '/usr/sbin/a2enconf phpmyadmin', 
		subscribe => File['/etc/apache2/conf-available/phpmyadmin.conf'],
	} 
	
	exec { 'apache2 phpmyadmin reload' : 
		command => '/usr/sbin/service apache2 reload', 
	} 

	# Configuration file for phpmyadmin
	file { '/etc/phpmyadmin/config.inc.php':
		owner => 'root',
		group => 'root',
		require => Package['phpmyadmin'],
		content => epp('/srv/puppet/files/config.inc.php.epp',
		{
			'controluser'	=> $controluser,
			'controlpass'	=> $controlpass,
			'pmadb'		=> $pmadb,
		},
		),
	}
}
