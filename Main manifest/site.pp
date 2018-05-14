node default {} 

node 'puppetlamp' {
	include lamp
	include users
	include osticket
	
	ssh_authorized_key { 'bobbix@puppetlamp':
		ensure          => present,
		user            => 'bobbix',
		type            => 'ssh-rsa',
		key             => 'Public key here'
	}

	user { 'bobbix':
		ensure          => present,
		password        => pw_hash("r0668236", "SHA-256", "mysalt"),
		shell           => "/bin/bash",
		home            => "/home/bobbix",
		managehome      => true,
		purge_ssh_keys  => true,
	}
} 

node 'puppetdatabase' {
	include database
	
	ssh_authorized_key { 'bobbix@puppetlamp':
		ensure          => present,
		user            => 'bobbix',
		type            => 'ssh-rsa',
		key             => 'Public key here'
	}

	user { 'bobbix':
		ensure          => present,
		password        => pw_hash("r0668236", "SHA-256", "mysalt"),
		shell           => "/bin/bash",
		home            => "/home/bobbix",
		managehome      => true,
		purge_ssh_keys  => true,
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
