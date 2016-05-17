class properties {

  pcmk_property { 'stonith-enabled' :
    ensure => 'present',
    value  => false,
  }

  pcmk_property { 'no-quorum-policy' :
    ensure => 'present',
    value  => 'ignore',
  }

}

include ::properties

class { '::pacemaker' :
  cluster_nodes    => ['node'],
  cluster_password => 'hacluster',

  # firewall is not needed on a signle node
  firewall_corosync_manage => false,
  firewall_pcsd_manage     => false,
}

Class['pacemaker'] ->
Class['properties']


