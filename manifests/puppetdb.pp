# Setup Puppetserver with PuppetDB
#
# == Parameters:
#
# $autosign:: Set up autosign entries. Set to true to enable naive autosigning.
#
# $autosign_entries:: List of autosign entries. Requires that autosign is pointing to the path of autosign.conf.
#
# $puppetdb_database_password:: Password for the puppetdb database in postgresql
#
# $timezone:: The timezone the server wants to be located in. Example: 'Europe/Helsinki'
class puppetmaster::puppetdb
(
  Variant[Boolean, String] $autosign = '/etc/puppetlabs/puppet/autosign.conf',
  Optional[Array[String]]  $autosign_entries = undef,
  String                   $puppetdb_database_password,
  String                   $timezone 
)
{

  $primary_names = [ "${facts['fqdn']}", "${facts['hostname']}", 'puppet', "puppet.${facts['domain']}" ]

  class { '::puppetmaster::puppetserver':
    server_reports   => 'store,puppetdb',
    autosign         => $autosign,
    autosign_entries => $autosign_entries,
    timezone         => $timezone, 
  }

  class { '::puppetdb':
    database_password => $puppetdb_database_password,
    ssl_deploy_certs  => true,
    database_validate => false,
  }

  class { '::puppetdb::master::config':
    puppetdb_server     => $facts['fqdn'],
    restart_puppet      => true,
  }
}
