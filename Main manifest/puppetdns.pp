node 'puppetdns' {
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
	
	class {'dns':
                ns              => 'puppetdns',
                root            => 'projecthosting',
                nsip           => '192.168.137.106',
                serial          => '4',
                arecords       => ['puppetdatabase.projecthosting.     IN      A       192.168.137.107',
                                'puppetdns.projecthosting.      IN      A       192.168.137.106',
                                'puppetlamp.projecthosting.     IN      A       192.168.137.105',
                                'puppet.projecthosting.         IN      A       192.168.137.104'],
        }
}
