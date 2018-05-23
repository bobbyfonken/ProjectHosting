node 'puppetdns' {
	include update
	include psacct
	
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
