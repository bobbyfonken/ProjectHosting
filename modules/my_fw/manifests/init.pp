class my_fw {

   # This class closes all ports en then open the basic ones
   stage { 'fw_pre':  before  => Stage['main']; }
   stage { 'fw_post': require => Stage['main']; }

   class { 'my_fw::pre':
     stage => 'fw_pre',
   }

   class { 'my_fw::post':
     stage => 'fw_post',
   }

  resources { "firewall":
     purge => true
  }

}
