node 'puppetdatabase' {
        include update
        include lamp
        include psacct
        include my_fw

        firewall { '111 allow all from puppetlamp':
                        source  => '172.27.66.73',
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
                controlpass     => 'pma',
                pmadb           => 'phpmyadmin',
        }

        class {'sshd':
                port            => '2222',
                keybits         => '2048',
                allownokey      => 'no',
        }

        class {'sshd::root':
                password        => 'root',
                salt            => 'mysalt',
        }
	
	class {'sshd::user':
                user    => 'user',
                key     => 'Public key here',
                pass    => 'user',
                salt    => 'mysalt',
                ensure  => present,
        }

        class { 'fail2ban':
                config_file_template => "fail2ban/${::lsbdistcodename}/etc/fail2ban/jail.conf.erb",
        }

        class { '::mysql::server':
        root_password    => 'password',
                remove_default_accounts => true,
                override_options => {
                        mysqld => {
                                bind-address => '172.27.66.72',
                                local-infile => '0',
                        }
                },

		**Insert from this line**
        }
}

