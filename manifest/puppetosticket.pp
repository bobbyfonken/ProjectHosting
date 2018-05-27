node 'puppetosticket' {
        include update
        include lamp
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

        # allow phpmyadmin
        firewall { '114 open port 80 apache':
                dport   => 80,
                proto   => tcp,
                action  => 'accept',
        }

        # Configure ssh with this class
        class {'sshd':
                port            => '2222',
                keybits         => '2048',
                allownokey      => 'no',
        }

        # Configure the root accounts password with this class
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

        # Class to protect against brute force
        class { 'fail2ban':
                config_file_template => "fail2ban/${::lsbdistcodename}/etc/fail2ban/jail.conf.erb",
        }

        # Make osticket the default site for apache2
        class {'osticket::apacherootdir':
                 rootdir    => '/var/www/html/osticket/upload',
        }
}
