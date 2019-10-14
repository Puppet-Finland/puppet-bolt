# @summary Setup Bolt controller
#
# Configure a Puppet Bolt controller node
#
# @example
#   include bolt::controller
#
class bolt::controller
(
  String $user
)
{

  include ::bolt::install

  # The root user requires special treatment
  $homedir = $user ? {
    'root'  => '/root',
    default => "/home/${user}"
  }
}
