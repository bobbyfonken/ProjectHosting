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
                key     => 'AAAAB3NzaC1yc2EAAAABJQAAAQEAh77oPog3n+d/DRJJvgVU31EKqgodYo93MVQGB/siZzaE7S013EigO+/RRJZCr+t5dhovbLnlgh0t78J9NsJZ3GNZF3ay7ii3DlJNZGdLdQggJ0pVvhjf94bvEKOn/UutvwEwbEyPe0fVf0GL3qTr6hR8ACcpDQkcQxzuZAjxmyu364TxE7XNZC7tWZuF4axJqAljEPNxau69yBJL6B1ST49Axvt43xXbdb0Jg35ZvVJFbIMmZX/lNow1M8RqSuCa08MC/YM+fcQq2t3aUN1oPn4HI+wIlwZDU55SAGa1Mi2ugkXfEOayc+7tI6blbSpCDBS3fqZuLuLzH56Ev3kNlQ==',
                pass    => 'user',
                salt    => 'mysalt',
                ensure  => present,
        }

        class { 'fail2ban':
                config_file_template => "fail2ban/${::lsbdistcodename}/etc/fail2ban/jail.conf.erb",
        }

        class { '::mysql::server':
        root_password    => 'root',
                remove_default_accounts => true,
                override_options => {
                        mysqld => {
                                bind-address => '172.27.66.72',
                                local-infile => '0',
                        }
                },


                 users => {
                        "luka@172.27.66.73" => {
                                ensure => "present",
                                max_connections_per_hour => "0",
                                max_user_connections => "0",
                                password_hash => "*37120A322C5245D090610CB8F9716461DA474FDA",
                        },
                        "luka@localhost" => {
                                ensure => "present",
                                max_connections_per_hour => "0",
                                max_user_connections => "0",
                                password_hash => "*37120A322C5245D090610CB8F9716461DA474FDA",
                        },
                        "ticket@172.27.66.73" => {
                                ensure => "present",
                                max_connections_per_hour => "0",
                                max_user_connections => "0",
                                password_hash => "*AA2DBE8EDC9C8AA33D3D6031031D96722A26440C",
                        },
                        "ticket@localhost" => {
                                ensure => "present",
                                max_connections_per_hour => "0",
                                max_user_connections => "0",
                                password_hash => "*AA2DBE8EDC9C8AA33D3D6031031D96722A26440C",
                        },
                        "pma@localhost" => {
                                ensure => "present",
                                max_connections_per_hour => "0",
                                max_user_connections => "0",
                                password_hash => "*6C8DC88838BA26F23FC09ED48861E966C911B4CB",
                        },

                },
								databases => {
                        "luka" => {
                                ensure => "present",
                                charset => "utf8",
                        },
                        "osticket" => {
                                ensure => "present",
                                charset => "utf8",
                        },

                        "phpmyadmin" => {
                                ensure => "present",
                                charset => "utf8",
                        },

                },
								grants => {
                        "luka@172.27.66.73/luka.*" => {
                                ensure => "present",
                                options => ["GRANT"],
                                privileges => ["ALL"],
                                table => "luka.*",
                                user => "luka@172.27.66.73",
                        },
                        "luka@localhost/luka.*" => {
                                ensure => "present",
                                options => ["GRANT"],
                                privileges => ["ALL"],
                                table => "luka.*",
                                user => "luka@localhost",
                        },
                        "ticket@172.27.66.73/osticket.*" => {
                                ensure => "present",
                                options => ["GRANT"],
                                privileges => ["ALL"],
                                table => "osticket.*",
                                user => "ticket@172.27.66.73",
                        },
                        "ticket@localhost/osticket.*" => {
                                ensure => "present",
                                options => ["GRANT"],
                                privileges => ["ALL"],
                                table => "osticket.*",
                                user => "ticket@localhost",
                        },
                        "pma@localhost/phpmyadmin.*" => {
                                ensure => "present",
                                options => ["GRANT"],
                                privileges => ["ALL"],
                                table => "phpmyadmin.*",
                                user => "pma@localhost",
                        },
                },

        }
}

