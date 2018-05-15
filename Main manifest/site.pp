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
