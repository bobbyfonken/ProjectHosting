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
}
