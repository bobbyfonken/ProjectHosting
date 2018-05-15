node default {} 

node 'puppet' {
        include sshd

	class {'sshd::user':
		user    => 'Bobbix',
		key     => 'Public key here',
		pass    => 'r0668236',
		salt    => 'mysalt',
		ensure  => present,
	}
}

node 'puppetdns' {
        include sshd

	class {'sshd::user':
		user    => 'Bobbix',
		key     => 'Public key here',
		pass    => 'r0668236',
		salt    => 'mysalt',
		ensure  => present,
	}

}

node 'puppetlamp' {
	include sshd
	include lamp
	include users
	include osticket
	
	class {'sshd::user':
		user    => 'Bobbix',
		key     => 'Public key here',
		pass    => 'r0668236',
		salt    => 'mysalt',
		ensure  => present,
	}
} 

node 'puppetdatabase' {
	include sshd
	include database
	
	class {'sshd::user':
		user    => 'Bobbix',
		key     => 'Public key here',
		pass    => 'r0668236',
		salt    => 'mysalt',
		ensure  => present,
	}
	
	class { '::mysql::server': 
	root_password    => 'r0668236',
		remove_default_accounts => true,
		override_options => {
			mysqld => {bind-address => '192.168.137.107'}
		},
		
		**Insert from this line**
	}
}
