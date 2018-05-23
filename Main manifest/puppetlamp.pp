node 'puppetlamp' {
	include update
	include lamp
	include lamp::userdir
	include users
	include osticket
	include psacct
	include my_fw
	
	firewall { '111 allow all from puppetdatabase':
                source  => '192.168.137.107',
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
	
	class {'lamp::vsftpd':
                port    => '2121',
                umask   => '022',
                vsftpdserverkey => 'vsftpdserverkey',
                vsftpdcertificate => 'vsftpdcertificate',
                freeusers => ['bobbix','root'],
        }
}
