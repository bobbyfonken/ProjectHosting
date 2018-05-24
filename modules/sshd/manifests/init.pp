class sshd
(String $port = '',
String $keybits = '',
String $allownokey = '',
){
        #install openssh-server package
        package { 'openssh-server' :
                ensure => latest,
        }

        #install ssh package
        package { 'ssh' :
                ensure => latest,
        }

        #Template config file
        file { '/etc/ssh/sshd_config':
                owner   => 'root',
                group   => 'root',
                content => epp('/srv/puppet/files/sshd_config.epp',
                {
                        'port'  => $port,
                        'keybits' => $keybits,
                        'allownokey' => $allownokey,
                },
                ),
        }

        #ensure ssh service is running
        service { 'ssh' :
        ensure => running,
                require => Package['openssh-server'],
        }

        #Restart ssh service
        exec { 'ssh reload' :
                command => '/usr/sbin/service ssh reload',
        }
}
