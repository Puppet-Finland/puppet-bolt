# @summary Setup Bolt controller
#
# Configure a Puppet Bolt controller node. Parameter defaults come from
# module-level Hiera.
#
# @param user
#   The local user that is used for outbound SSH connections.
# @param puppetdb_url
#   URL to the PuppetDB instance that provides data for the inventory
# @param inventory_template_source
#   Puppet Bolt inventory template path. The inventory will be populated by
#   "bolt-inventory-pdb".
# @param bolt_inventory_pdb
#   Path to the inventory update script
# @param cacert
#   The CA certificate used when connecting to PuppetDB
# @param cert
#   The certificate used when connecting to PuppetDB
# @param key
#   The private key used when connecting to PuppetDB
# @param hourly_inventory_updates
#   The number of inventory updates per hour
# @param cron_email
#   Email address for cron reports
# @param inventory
#   Path to the inventory file. Defaults to ~/inventory.yaml of the Bolt user.
#
# @example
#   class { '::bolt::controller':
#     user                      => 'bolt',
#     puppetdb_url              => 'https://puppet.example.org:8081',
#     inventory_template_source => '/home/bolt/inventory-template.yaml',
#   }
#
class bolt::controller
(
  String           $user,
  String           $puppetdb_url,
  String           $inventory_template_source,
  String           $bolt_inventory_pdb,
  String           $cacert,
  String           $cert,
  String           $key,
  Integer          $hourly_inventory_updates,
  String           $cron_email,
  Optional[String] $inventory = undef,
)
{

  include ::bolt::install

  # The root user requires special treatment
  $homedir = $user ? {
    'root'  => '/root',
    default => "/home/${user}"
  }

  $inventory_file = $inventory ? {
    undef   => "${homedir}/inventory.yaml",
    default => $inventory,
  }

  cron { 'update-bolt-inventory-from-puppetdb':
    command     => "${bolt_inventory_pdb} ${inventory_template_source} --cacert ${cacert} --cert ${cert} --key ${key} --url ${puppetdb_url} -o ${inventory_file}",
    user        => 'root',
    minute      => "*/${hourly_inventory_updates}",
    environment => [ 'PATH=/bin:/usr/bin:/usr/local/bin:/opt/puppetlabs/bin', "MAILTO=${cron_email}" ],
  }

  file { $inventory_file:
    ensure => 'present',
    owner  => $user,
    group  => $user,
    mode   => '0600',
  }
}
