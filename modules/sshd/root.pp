class sshd::root (String $password = '', String $salt = ''){
	# class for controlling the root accounts
	user { 'root':
		ensure          => present,
		password        => pw_hash($password, "SHA-256", $salt),
		uid             => "0",
	}
}
