class sshd::user (String $user = '', String $key = '', String $pass = '', String $salt = '', String $ensure = ''){
        ssh_authorized_key { '${user}@puppet':
                ensure          => $ensure,
                user            => $user,
                type            => 'ssh-rsa',
                key             => $key,
        }

        user { $user:
                ensure          => $ensure,
                password        => pw_hash($pass, "SHA-256", $salt),
                shell           => "/bin/bash",
                home            => "/home/${user}",
                managehome      => true,
                purge_ssh_keys  => true,
        }
}
