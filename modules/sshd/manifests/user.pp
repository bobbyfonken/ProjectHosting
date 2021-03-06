class sshd::user (String $user = '', String $key = '', String $pass = '', String $salt = '', String $ensure = ''){
        # Set the public key for this user to have remote access
        ssh_authorized_key { '${user}@puppet':
                ensure          => $ensure,
                user            => $user,
                type            => 'ssh-rsa',
                key             => $key,
        }

        # Make this user an admin user
        user { $user:
                ensure          => $ensure,
                password        => pw_hash($pass, "SHA-256", $salt),
                shell           => "/bin/bash",
                groups          => ['adm', 'cdrom', 'sudo', 'dip', 'lxd'],
                home            => "/home/${user}",
                managehome      => true,
                purge_ssh_keys  => true,
        }
}
