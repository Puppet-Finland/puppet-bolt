# bolt

Puppet module for managing Puppet Bolt.

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with bolt](#setup)
    * [What bolt affects](#what-bolt-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

Install Puppet Bolt on Bolt controllers. Optionally configure automatic
PuppetDB inventory updates.

## Setup

### What bolt affects

On Bolt controllers this module manages:

* Puppet Bolt installation from Puppetlabs' puppet-tools-release repositories
* Optional features
    * Setting up and keeping a PuppetDB-based inventory up-to-date

### Setup Requirements

Managing local system users, SSH and sudo are outside of the scope of this
module. You can use the
[ssh_sudoers](https://github.com/Puppet-Finland/puppet-ssh_sudoers) module to
handle that part.

## Usage

Install Bolt:

    include ::bolt::install

Install Bolt and setup Bolt Controller node with PuppetDB inventory from a
profile:

    $inventory_path = '/root/inventory.yaml'
    $inventory_template_path = '/root/inventory-template.yaml'
    
    file { $inventory_template_path:
      ensure  => 'present',
      content => template('profile/inventory-template.yaml.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
    }
    
    class { '::bolt::controller':
      user                    => 'root',
      puppetdb_url            => 'https://puppet.example.org:8081',
      inventory_path          => $inventory_path,
      inventory_template_path => $inventory_template_path,
      require                 => File[$inventory_template_path],
     }

## Limitations

There are a couple of "by design" limitations:

* Local system users are not managed on the controller
* Generic SSH and sudo configurations must be handled outside this module, with [puppet-sshd_sudoers](https://github.com/Puppet-Finland/puppet-ssh_sudoers) or something similar. This is to keep this module Bolt-specific and the sshd_sudoers module usable with Ansible, Fabric and other SSH-based management tools.
* Target nodes do not require Bolt-specific configurations so they are not touched by this module.

Other limitions are:

* Controller setup is only supported for Debian derivatives; adding support for RedHat or other platforms would be fairly easy.

## Development

Pull requests are welcome.
