node 'puppetdatabase' {
	include sshd
	include database
	
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
	
	class { '::mysql::server': 
	root_password    => 'r0668236',
		remove_default_accounts => true,
		override_options => {
			mysqld => {
                                bind-address => '192.168.137.107',
                                local-infile => '0',
                        }
		},
		
		**Insert from this line**
	}
}
