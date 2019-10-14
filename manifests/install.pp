# @summary install Puppet Bolt
#
# @example
#   include ::bolt::install
#
class bolt::install {

  case $::osfamily {
    'Debian': {
      ::apt::source { 'puppet-tools-release':
        comment  => 'Puppet tools release repository',
        location => 'http://apt.puppet.com',
        release  => $::lsbdistcodename,
        repos    => 'puppet-tools',
        key      => {
          id     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
          server => 'keyserver.ubuntu.com',
        }
      }
      package { 'puppet-bolt':
        ensure  => 'present',
        require => Apt::Source['puppet-tools-release'],
      }
    }
    default: { fail('Currently ::bolt::install class only works on Debian derivatives!') }
  }
}
