node 'puppet' {
        include update
        include psacct
        
        firewall { '109 allow all from puppetlamp':
                source  => '172.27.66.73',
                proto   => 'all',
                action  => 'accept',
        }

        firewall { '110 allow all from puppetdns':
                source  => '172.27.66.71',
                proto   => 'all',
                action  => 'accept',
        }

        firewall { '111 allow all from puppetdatabase':
                source  => '172.27.66.72',
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
}

