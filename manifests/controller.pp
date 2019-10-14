# @summary Setup Bolt controller
#
# Configure a Puppet Bolt controller node
#
# @param user
#   The local user that is used for outbound SSH connections.
# @param inventory_template_source
#   Inventory template file for Puppet Bolt. The inventory will be populated by "bolt-inventory-pdb".
# @example
#   include bolt::controller
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
