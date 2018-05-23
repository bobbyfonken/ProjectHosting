node 'puppetdatabase' {
	include update
	include lamp
	include lamp::phpmyadmin
	include psacct
	include my_fw
	
	firewall { '111 allow all from puppetlamp':
			source  => '192.168.137.105',
			proto   => 'all',
			action  => 'accept',
	}
		
	# default port used by puppet
	firewall { '112 open port 8140':
			dport   => 8140,
			proto   => tcp,
			action  => 'accept',
	}

	# port number should be the same as the one from sshd below
	firewall { '113 open port 2222 sshd':
			dport   => 2222,
			proto   => tcp,
			action  => 'accept',
	}

	# allow phpmyadmin
	firewall { '114 open port 80 apache':
			dport   => 80,
			proto   => tcp,
			action  => 'accept',
	}
	
	# This should be the same as the pma user, database, and password
	class {'lamp::phpmyadmin':
		controluser     => 'pma',
		controlpass     => 'r0668236',
		pmadb           => 'phpmyadmin',
	}
	
	class {'sshd':
                port            => '2222',
                keybits         => '2048',
                allownokey      => 'no',
        }
	
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
	
	class { 'fail2ban':
		config_file_template => "fail2ban/${::lsbdistcodename}/etc/fail2ban/jail.conf.erb",
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
