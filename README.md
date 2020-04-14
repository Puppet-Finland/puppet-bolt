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

Install Puppet Bolt on Bolt controllers. Optionally configure connectivity
to PuppetDB for PuppetDB-based inventories.

## Setup

### What bolt affects

On Bolt controllers this module manages:

* Puppet Bolt installation from Puppetlabs' puppet-tools-release repositories
* Optional features
    * Setting up certificates/keys for Bolt inventory v2 PuppetDB plugin

### Setup Requirements

Managing local system users, SSH and sudo are outside of the scope of this
module. You can use the
[ssh_sudoers](https://github.com/Puppet-Finland/puppet-ssh_sudoers) module to
handle that part.

## Usage

Install Bolt:

    include ::bolt::install

Install Bolt and reuse the node's Puppet certificates for connecting to
PuppetDB. The inventory and bolt configuration is assumed to be in the control
repository:

    user { 'bolt':
      ensure     => 'present',
      managehome => true,
    }
    
    ::bolt::controller { 'mysite':
      user                          => 'bolt',
      use_puppet_certs_for_puppetdb => true,
      require                       => User['bolt'],
    }

It is also possible to define cert/key contents manually instead of using
Puppet certificates.

## Limitations

There are a couple of "by design" limitations:

* Local system users are not managed on the controller
* Generic SSH and sudo configurations must be handled outside this module, with [puppet-sshd_sudoers](https://github.com/Puppet-Finland/puppet-ssh_sudoers) or something similar. This is to keep this module Bolt-specific and the sshd_sudoers module usable with Ansible, Fabric and other SSH-based management tools.
* Target nodes do not require Bolt-specific configurations so they are not touched by this module.

## Development

Pull requests are welcome.
