class psact {
        #install psact package
        package { 'acct' :
                ensure => latest,
        }

        #ensure psact service is running
        service { 'acct' :
                ensure => running,
                require => Package['acct'],
        }
}
