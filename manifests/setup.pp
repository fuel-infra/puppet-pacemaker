# == Class: pacemaker::setup
#
# Sets ups the cluster configuration
# either using the "pcsd" service or
# by creating the configuration file directy.
#
class pacemaker::setup (
  $pcsd_mode            = $::pacemaker::params::pcsd_mode,
  $cluster_nodes        = $::pacemaker::params::cluster_nodes,
  $cluster_rrp_nodes    = $::pacemaker::params::cluster_rrp_nodes,
  $cluster_name         = $::pacemaker::params::cluster_name,
  $cluster_auth_key     = $::pacemaker::params::cluster_auth_key,
  $cluster_auth_enabled = $::pacemaker::params::cluster_auth_enabled,
  $cluster_setup        = $::pacemaker::params::cluster_setup,
  $cluster_options      = $::pacemaker::params::cluster_options,
  $cluster_user         = $::pacemaker::params::cluster_user,
  $cluster_group        = $::pacemaker::params::cluster_group,
  $cluster_password     = $::pacemaker::params::cluster_password,
  $pcs_bin_path         = $::pacemaker::params::pcs_bin_path,
  $cluster_config_path  = $::pacemaker::params::cluster_config_path,
  $cluster_interfaces   = $::pacemaker::params::cluster_interfaces,
  $cluster_log_subsys   = $::pacemaker::params::cluster_log_subsys,
  $plugin_version       = $::pacemaker::params::plugin_version,
  $log_file_path        = $::pacemaker::params::log_file_path,
) inherits ::pacemaker::params {
  if $::osfamily == 'Debian' {
    class { '::pacemaker::setup::debian' :
      plugin_version => $plugin_version,
    }
    contain 'pacemaker::setup::debian'
  }

  class { '::pacemaker::setup::auth_key' :
    cluster_auth_enabled => $cluster_auth_enabled,
    cluster_auth_key     => $cluster_auth_key,
    cluster_user         => $cluster_user,
    cluster_group        => $cluster_group,
  }
  contain 'pacemaker::setup::auth_key'

  if $pcsd_mode {
    class { '::pacemaker::setup::pcsd' :
      cluster_nodes     => $cluster_nodes,
      cluster_rrp_nodes => $cluster_rrp_nodes,
      cluster_name      => $cluster_name,
      cluster_setup     => $cluster_setup,
      cluster_options   => $cluster_options,
      cluster_user      => $cluster_user,
      cluster_group     => $cluster_group,
      cluster_password  => $cluster_password,
      pcs_bin_path      => $pcs_bin_path,
    }
    contain 'pacemaker::setup::pcsd'
  } else {
    class { '::pacemaker::setup::config' :
      cluster_nodes        => $cluster_nodes,
      cluster_rrp_nodes    => $cluster_rrp_nodes,
      cluster_name         => $cluster_name,
      cluster_auth_enabled => $cluster_auth_enabled,
      cluster_setup        => $cluster_setup,
      cluster_options      => $cluster_options,
      cluster_config_path  => $cluster_config_path,
      cluster_interfaces   => $cluster_interfaces,
      cluster_log_subsys   => $cluster_log_subsys,
      log_file_path        => $log_file_path,
    }
    contain 'pacemaker::setup::config'
  }
}
