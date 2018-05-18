node 'puppetlamp' {
	include sshd
	include lamp
	include users
	include osticket
	
	class {'sshd::root':
		password        => 'r0668236',
		salt            => 'mysalt',
	}
	
	class {'sshd::user':
		user    => 'bobbix',
		key     => 'Public key here',
		pass    => 'r0668236',
		salt    => 'mysalt',
		ensure  => present,
	}
}
