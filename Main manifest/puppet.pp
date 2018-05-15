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
