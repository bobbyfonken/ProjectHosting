class dns (
String $root = '',
String $ns = '',
String $nsip = '',
String $serial = '',
Array $arecords = '',
){
	# install bind9
	package { 'bind9':
			ensure => 'installed',
	}
	
	# ensure bind9 is running
	service { 'bind9':
			ensure => 'running',
			enable => true,
			require => Package['bind9'],
	}
	
	# install dns toubleshooting tools
	package { 'dnsutils':
			ensure => 'installed',
	
	}
	
	# template file for your zone
	file { '/etc/bind/named.conf.local':
		notify	=> Service['bind9'],
		mode	=> '0640',
		owner	=> 'root',
		group	=> 'bind',
		require	=> Package['bind9'],
		content	=> epp('/srv/puppet/files/named.conf.local.epp',
		{
			'root2'	=> $root,
		},
		),
	}

	# Make directory for zone
	file { '/etc/bind/zones/':
			ensure => 'directory',
			owner  => 'root',
			group  => 'bind',
			mode   => '0755',
			require	=> Package['bind9'],
	}
	
	# template file for your forward lookup zone
	file { '/etc/bind/zones/projecthosting':
			notify  => Service['bind9'],
			mode    => '0640',
			owner   => 'root',
			group   => 'bind',
			require => Package['bind9'],
			subscribe => File['/etc/bind/zones/'],
			content => epp('/srv/puppet/files/projecthosting.epp',
			{
				'root'		=> $root,
				'ns'		=> $ns,
				'nsip'		=> $nsip,
				'serial'	=> $serial,
				'arecords'	=> $arecords,
			},
			),
	}
}
