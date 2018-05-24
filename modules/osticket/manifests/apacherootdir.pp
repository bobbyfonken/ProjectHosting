class osticket::apacherootdir 
(
String $rootdir = '',
){

	# Make osticket the default site
	file { '/etc/apache2/sites-available/000-default.conf':
		ensure => 'present',
		owner  => 'root',
		group  => 'root',
		mode   => '0600',
		content	=> epp('/srv/puppet/files/000-default.conf.epp',
		{
			'rootdir'  => $rootdir,
		},
		),
	}
	
	# Enable default site osticket
	exec { 'a2ensite 000-default.conf' :
		command => '/usr/sbin/a2ensite 000-default.conf',
		subscribe => File['/etc/apache2/sites-available/000-default.conf'],
	}
}
