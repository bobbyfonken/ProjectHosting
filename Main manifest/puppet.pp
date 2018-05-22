node 'puppet' {
	include update
	include psacct
	
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
}
