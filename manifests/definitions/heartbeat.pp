define heartbeat ($owned_resources = '', $key = '', $iface = 'eth0', $auth_method = 'sha1', $ensure = 'present') {
    $clusterkey = $key ? {
        ""      => $name,
        default => $method ? {
            'crc'   => '',
            default => $key,
        }
    }

    package { "heartbeat": ensure => $ensure }


    case $ensure {
        present: {
            file { '/etc/heartbeat/authkeys':
                ensure  => $ensure,
                owner   => 'root',
                mode    => 600,
                content => template('heartbeat/authkeys.erb'),
                require => Package['heartbeat'],
                notify  => Service['heartbeat'],
            }

            common::concatfilepart { "ha.cf.$fqdn.header":
                ensure  => $ensure,
                manage  => true,
                file    => '/etc/heartbeat/ha.cf',
                content => template("heartbeat/ha.cf.erb"),
                tag     => $name,
                require => Package['heartbeat'],
                notify  => Service['heartbeat'],
            }

            @@common::concatfilepart { "ha.cf.$fqdn.trailer":
                ensure  => $ensure,
                manage  => true,
                file    => '/etc/heartbeat/ha.cf',
                content => "node\t\t\t$fqdn\n",
                tag     => $name,
                require => Package['heartbeat'],
                notify  => Service['heartbeat'],
            }

            if $owned_resources {
                @@common::concatfilepart { "haresources.$fqdn":
                    ensure  => $ensure,
                    manage  => true,
                    file    => '/etc/heartbeat/haresources',
                    content => template('heartbeat/haresources.erb'),
                    tag     => $name,
                    require => Package['heartbeat'],
                    notify  => Service['heartbeat'],
                }
            }

            Common::Concatfilepart <<| tag == "$name" |>>

            service { 'heartbeat':
                ensure    => running,
                enable    => true,
                hasstatus => true,
                require   => Package['heartbeat'],
            }
        }
        absent: {
            service { 'heartbeat':
                ensure    => stopped,
                enable    => false,
                hasstatus => true,
                before    => Package['heartbeat'],
            }
        }
    }
}

# vim modeline - have 'set modeline' and 'syntax on' in your ~/.vimrc.
# vi:syntax=puppet:filetype=puppet:ts=4:et:
