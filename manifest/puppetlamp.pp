node 'puppetlamp' {
        include update
        include lamp
        include lamp::userdir
        include users
        include osticket
        include psacct
        include my_fw

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

        # allow vsftpd connection (same port as you used as below)
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
        # allow vsftpd passive
        firewall { '117 open port 1024 vsftpd passive':
                sport   => 1024,
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
                key     => 'AAAAB3NzaC1yc2EAAAABJQAAAQEAh77oPog3n+d/DRJJvgVU31EKqgodYo93MVQGB/siZzaE7S013EigO+/RRJZCr+t5dhovbLnlgh0t78J9NsJZ3GNZF3ay7ii3DlJNZGdLdQggJ0pVvhjf94bvEKOn/UutvwEwbEyPe0fVf0GL3qTr6hR8ACcpDQkcQxzuZAjxmyu364TxE7XNZC7tWZuF4axJqAljEPNxau69yBJL6B1ST49Axvt43xXbdb0Jg35ZvVJFbIMmZX/lNow1M8RqSuCa08MC/YM+fcQq2t3aUN1oPn4HI+wIlwZDU55SAGa1Mi2ugkXfEOayc+7tI6blbSpCDBS3fqZuLuLzH56Ev3kNlQ==',
                pass    => 'user',
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

