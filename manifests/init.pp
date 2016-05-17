class pacemaker (
  $firewall_ipv6_manage     = $::pacemaker::params::firewall_ipv6_manage,
  $firewall_corosync_manage = $::pacemaker::params::firewall_corosync_manage,
  $firewall_corosync_ensure = $::pacemaker::params::firewall_corosync_ensure,
  $firewall_corosync_dport  = $::pacemaker::params::firewall_corosync_dport,
  $firewall_corosync_proto  = $::pacemaker::params::firewall_corosync_proto,
  $firewall_corosync_action = $::pacemaker::params::firewall_corosync_action,
  $firewall_pcsd_manage     = $::pacemaker::params::firewall_pcsd_manage,
  $firewall_pcsd_ensure     = $::pacemaker::params::firewall_pcsd_ensure,
  $firewall_pcsd_dport      = $::pacemaker::params::firewall_pcsd_dport,
  $firewall_pcsd_action     = $::pacemaker::params::firewall_pcsd_action,

  $package_manage   = $::pacemaker::params::package_manage,
  $package_list     = $::pacemaker::params::package_list,
  $package_ensure   = $::pacemaker::params::package_ensure,
  $package_provider = $::pacemaker::params::package_provider,

  $pcsd_mode           = $::pacemaker::params::pcsd_mode,

  $cluster_nodes       = $::pacemaker::params::cluster_nodes,
  $cluster_rrp_nodes   = $::pacemaker::params::cluster_rrp_nodes,
  $cluster_name        = $::pacemaker::params::cluster_name,
  $cluster_auth_key    = $::pacemaker::params::cluster_auth_key,
  $cluster_setup       = $::pacemaker::params::cluster_setup,
  $cluster_options     = $::pacemaker::params::cluster_options,
  $cluster_user        = $::pacemaker::params::cluster_user,
  $cluster_password    = $::pacemaker::params::cluster_password,
  $pcs_bin_path        = $::pacemaker::params::pcs_bin_path,

  $cluster_config_path = $::pacemaker::params::cluster_config_path,
  $cluster_interfaces  = $::pacemaker::params::cluster_interfaces,
  $cluster_log_subsys  = $::pacemaker::params::cluster_log_subsys,
  $plugin_version      = $::pacemaker::params::plugin_version,
  $log_file_path       = $::pacemaker::params::log_file_path,

  $pcsd_manage        = $::pacemaker::params::pcsd_manage,
  $pcsd_enable        = $::pacemaker::params::pcsd_enable,
  $pcsd_service       = $::pacemaker::params::pcsd_service,
  $pcsd_provider      = $::pacemaker::params::pcsd_provider,
  $corosync_manage    = $::pacemaker::params::corosync_manage,
  $corosync_enable    = $::pacemaker::params::corosync_enable,
  $corosync_service   = $::pacemaker::params::corosync_service,
  $corosync_provider  = $::pacemaker::params::corosync_provider,
  $pacemaker_manage   = $::pacemaker::params::pacemaker_manage,
  $pacemaker_enable   = $::pacemaker::params::pacemaker_enable,
  $pacemaker_service  = $::pacemaker::params::pacemaker_service,
  $pacemaker_provider = $::pacemaker::params::pacemaker_provider,
) inherits ::pacemaker::params {

  class { '::pacemaker::firewall' :
    firewall_ipv6_manage     => $firewall_ipv6_manage,
    firewall_corosync_manage => $firewall_corosync_manage,
    firewall_corosync_ensure => $firewall_corosync_ensure,
    firewall_corosync_dport  => $firewall_corosync_dport,
    firewall_corosync_proto  => $firewall_corosync_proto,
    firewall_corosync_action => $firewall_corosync_action,
    firewall_pcsd_manage     => $firewall_pcsd_manage,
    firewall_pcsd_ensure     => $firewall_pcsd_ensure,
    firewall_pcsd_dport      => $firewall_pcsd_dport,
    firewall_pcsd_action     => $firewall_pcsd_action,
  }

  class { '::pacemaker::install' :
    package_manage   => $package_manage,
    package_list     => $package_list,
    package_ensure   => $package_ensure,
    package_provider => $package_provider,
  }

  class { '::pacemaker::setup' :
    pcsd_mode           => $pcsd_mode,
    # pcsd only
    cluster_nodes       => $cluster_nodes,
    cluster_rrp_nodes   => $cluster_rrp_nodes,
    cluster_name        => $cluster_name,
    cluster_auth_key    => $cluster_auth_key,
    cluster_setup       => $cluster_setup,
    cluster_options     => $cluster_options,
    cluster_user        => $cluster_user,
    cluster_password    => $cluster_password,
    pcs_bin_path        => $pcs_bin_path,
    # config only
    cluster_config_path => $cluster_config_path,
    cluster_interfaces  => $cluster_interfaces,
    cluster_log_subsys  => $cluster_log_subsys,
    plugin_version      => $plugin_version,
    log_file_path       => $log_file_path,
  }

  class { '::pacemaker::service' :
    pcsd_manage        => $pcsd_manage,
    pcsd_enable        => $pcsd_enable,
    pcsd_service       => $pcsd_service,
    pcsd_provider      => $pcsd_provider,
    corosync_manage    => $corosync_manage,
    corosync_enable    => $corosync_enable,
    corosync_service   => $corosync_service,
    corosync_provider  => $corosync_provider,
    pacemaker_manage   => $pacemaker_manage,
    pacemaker_enable   => $pacemaker_enable,
    pacemaker_service  => $pacemaker_service,
    pacemaker_provider => $pacemaker_provider,
  }

  contain 'pacemaker::firewall'
  contain 'pacemaker::install'
  contain 'pacemaker::setup'
  contain 'pacemaker::service'

  Class['::pacemaker::firewall'] ->
  Class['::pacemaker::install']

  Class['::pacemaker::install'] ->
  Class['::pacemaker::service']

  Class['::pacemaker::install'] ->
  Class['::pacemaker::setup']

}
