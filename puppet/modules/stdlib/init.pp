class apacheclassname {
        package { 'apache2':
                provider=>'apt',
                ensure=>'installed'
        }

        notify { 'Apache2 is installed.':
        }

        service { 'apache2':
                ensure=>'running'
        }

        notify { 'Apache2 is running.':
        }
}
