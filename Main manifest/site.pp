node default {}

node 'puppetlamp' {
	include lamp
	include users
	
	class { '::mysql::server':
		root_password	=> 'r0668236',
				
        
	}
}
