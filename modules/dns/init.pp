class dns {
	package { 'bind9':
			ensure => 'installed',
	}
	
	service { 'bind9':
			ensure => 'running',
			enable => true,
			require => Package['bind9'],
	}
	
	package { 'dnsutils':
			ensure => 'installed',
	
	}
	
	file { '/etc/bind/named.conf.local':
		notify	=> Service['bind9'],
		mode	=> '0640',
		owner	=> 'root',
		group	=> 'bind',
		require	=> Package['bind9'],
		content	=> template('/srv/puppet/files/named.conf.local'),
	}

	# Make directory for zone files
	file { '/etc/bind/zones/':
			ensure => 'directory',
			owner  => 'root',
			group  => 'bind',
			mode   => '0755',
			require	=> Package['bind9'],
	}
	
	file { '/etc/bind/zones/projecthosting':
			notify  => Service['bind9'],
			mode    => '0640',
			owner   => 'root',
			group   => 'bind',
			require => Package['bind9'],
			content => template('/srv/puppet/files/projecthosting'),
      subscribe => File['/etc/bind/zones/'],
	}
}
