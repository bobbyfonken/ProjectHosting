node 'puppetlamp' {
        include update
        include lamp
        include lamp::userdir
        include users
        include osticket
        include psacct
        include my_fw

        # Firewall rules to configure
        firewall { '111 allow all from puppetdatabase':
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

        # allow apache2
        firewall { '114 open port 80 apache2':
                dport   => 80,
                proto   => tcp,
                action  => 'accept',
        }

        # allow vsftpd connection (same port as you used as below in class lamp::vsftpd)
        firewall { '115 open port 2121 vsftpd':
                dport   => 2121,
                proto   => tcp,
                action  => 'accept',
        }

        # allow vsftpd upload
        firewall { '116 open port 20 vsftpd upload':
                sport   => 20,
                proto   => tcp,
                action  => 'accept',
        }

        # allow vsftpd passive (lowest and highest portnumbers must match like below lamp::vsftpd)
        firewall { '117 open ports for vsftpd passive':
                dport   => [10098, 10099, 10100],
                proto   => tcp,
                action  => 'accept',
        }

        # Configure ssh with this class
        class {'sshd':
                port            => '2222',
                keybits         => '2048',
                allownokey      => 'no',
        }

        # Configure the root accounts password
        class {'sshd::root':
                password        => 'root',
                salt            => 'mysalt',
        }

        # Configure remote access for this user and make him administrator
        class {'sshd::user':
                user    => 'user',
                key     => 'Public key here',
                pass    => 'user',
                salt    => 'mysalt',
                ensure  => present,
        }

        # class to protect against brute force
        class { 'fail2ban':
                config_file_template => "fail2ban/${::lsbdistcodename}/etc/fail2ban/jail.conf.erb",
        }

        # Configure vsftpd with this class
        class {'lamp::vsftpd':
                 port    => '2121',
                umask   => '022',
                vsftpdserverkey => 'vsftpdserverkey',
                vsftpdcertificate => 'vsftpdcertificate',
                pasvmaxport => '10100',
                pasvminport => '10098',
                freeusers => ['bobbix','root'],
        }
}

