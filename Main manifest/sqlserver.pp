class { '::mysql::server': 
    root_password    => 'r0668236',
		remove_default_accounts => true,
		
    override_options => {
			mysqld => {bind-address => '192.168.137.107'}
		},
		
		**Insert from this line**
	}
