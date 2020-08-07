# @summary Setup Bolt controller
#
# Configure a Puppet Bolt controller node. Parameter defaults come from
# module-level Hiera.
#
# @param id
#   An identifier for this particular PuppetDB connection. This is used as
#   a part of the certificate path to distinguish between multiple control
#   repositories/inventories.
# @param user
#   The local user that is used for outbound SSH connections.
# @param use_puppet_certs_for_puppetdb
#   Reuse existing Puppet certificates for PuppetDB connections. If you define
#   this you won't need to define any of the other content/source
#   parameters, assuming the certificate filename matches "${::fqdn}.pem".
# @param cacert_content
#   Content of the CA certificate used when connecting to PuppetDB
# @param cacert_source
#   Source for the CA certificate used when connecting to PuppetDB
# @param cert_content
#   Content of the certificate used when connecting to PuppetDB
# @param cert_source
#   Source for the certificate used when connecting to PuppetDB
# @param key_content
#   Content of the private key used when connecting to PuppetDB
# @param key_source
#   Source for the private key used when connecting to PuppetDB
#
class bolt::controller
(
  String           $id,
  String           $user,
  Boolean          $use_puppet_certs_for_puppetdb = true,
  Optional[String] $cacert_source = undef,
  Optional[String] $cacert_content = undef,
  Optional[String] $cert_source = undef,
  Optional[String] $cert_content = undef,
  Optional[String] $key_source = undef,
  Optional[String] $key_content = undef,
)
{

  include ::bolt::install

  # The root user requires special treatment
  $homedir = $user ? {
    'root'  => '/root',
    default => "/home/${user}"
  }

  # Create directory structure required for certificates used by Bolt to reach out
  # to PuppetDB
  file {[ "${homedir}/.puppetlabs",
          "${homedir}/.puppetlabs/etc",
          "${homedir}/.puppetlabs/etc/bolt",
          "${homedir}/.puppetlabs/etc/bolt/${id}",
          "${homedir}/.puppetlabs/etc/bolt/${id}/ssl",
          "${homedir}/.puppetlabs/etc/bolt/${id}/ssl/certs",
          "${homedir}/.puppetlabs/etc/bolt/${id}/ssl/private_keys", ]:
          ensure => 'directory',
          owner  => $user,
          group  => $user,
          mode   => '0750',
  }

  # If this node is joined to the same Puppetmaster as the PuppetDB we can reuse
  # this node's Puppet certificates for PuppetDB connections.
  if $use_puppet_certs_for_puppetdb {
    $_cacert_source  = '/etc/puppetlabs/puppet/ssl/certs/ca.pem'
    $_cert_source  = "/etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem"
    $_key_source  = "/etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem"
  } else {
    $_cacert_source  = $cacert_source
    $_cert_source  = $cert_source
    $_key_source  = $key_source
  }

  file {
    default:
      ensure => 'present',
      owner  => $user,
      group  => $user,
      mode   => '0640',
    ;
    ["${homedir}/.puppetlabs/etc/bolt/${id}/ssl/certs/cert.pem"]:
      source  => $_cert_source,
      content => $cert_content,
      require => File["${homedir}/.puppetlabs/etc/bolt/${id}/ssl/certs"],
    ;
    ["${homedir}/.puppetlabs/etc/bolt/${id}/ssl/certs/ca.pem"]:
      source  => $_cacert_source,
      content => $cacert_content,
      require => File["${homedir}/.puppetlabs/etc/bolt/${id}/ssl/certs"],
    ;
    ["${homedir}/.puppetlabs/etc/bolt/${id}/ssl/private_keys/key.pem"]:
      source  => $_key_source,
      content => $key_content,
      require => File["${homedir}/.puppetlabs/etc/bolt/${id}/ssl/private_keys"],
    ;
  }
}
