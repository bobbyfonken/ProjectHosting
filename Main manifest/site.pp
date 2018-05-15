node default {} 

node 'puppet' {
        include sshd

        ssh_authorized_key { 'bobbix@puppet':
                ensure          => present,
                user            => 'bobbix',
                type            => 'ssh-rsa',
                key             => 'Public key here'
        }

        user { 'bobbix':
                ensure          => present,
                password        => pw_hash("r0668236", "SHA-256", "mysalt"),
                shell           => "/bin/bash",
                home            => "/home/bobbix",
                managehome      => true,
                purge_ssh_keys  => true,
        }
}

node 'puppetdns' {
        include sshd

        ssh_authorized_key { 'bobbix@puppetdns':
                ensure          => present,
                user            => 'bobbix',
                type            => 'ssh-rsa',
                key             => 'Public key here'
        }

        user { 'bobbix':
                ensure          => present,
                password        => pw_hash("r0668236", "SHA-256", "mysalt"),
                shell           => "/bin/bash",
                home            => "/home/bobbix",
                managehome      => true,
                purge_ssh_keys  => true,
        }

}

node 'puppetlamp' {
	include sshd
	include lamp
	include users
	include osticket
	
	ssh_authorized_key { 'bobbix@puppetlamp':
		ensure          => present,
		user            => 'bobbix',
		type            => 'ssh-rsa',
		key             => 'Public key here'
	}

	user { 'bobbix':
		ensure          => present,
		password        => pw_hash("r0668236", "SHA-256", "mysalt"),
		shell           => "/bin/bash",
		home            => "/home/bobbix",
		managehome      => true,
		purge_ssh_keys  => true,
	}
} 

node 'puppetdatabase' {
	include sshd
	include database
	include ::mysql::server
	
	ssh_authorized_key { 'bobbix@puppetlamp':
		ensure          => present,
		user            => 'bobbix',
		type            => 'ssh-rsa',
		key             => 'Public key here'
	}

	user { 'bobbix':
		ensure          => present,
		password        => pw_hash("r0668236", "SHA-256", "mysalt"),
		shell           => "/bin/bash",
		home            => "/home/bobbix",
		managehome      => true,
		purge_ssh_keys  => true,
	}
}
