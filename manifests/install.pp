# == Class: pacemaker::install
#
# Install the required Pacemaker and Corosync packages
# and the basic configuration folders.
#
# [*package_manage*]
#   Should the packages be managed?
#   Default: true
#
# [*package_list*]
#   The list of packages names to install
#
# [*package_ensure*]
#   Ensure parameter of the packages (present,installed,absent,purged)
#
# [*package_provider]
#   Override the default package provider
#   Default: undef
#
class pacemaker::install (
  $package_manage   = $::pacemaker::params::package_manage,
  $package_list     = $::pacemaker::params::package_list,
  $package_ensure   = $::pacemaker::params::package_ensure,
  $package_provider = $::pacemaker::params::package_provider,
) inherits ::pacemaker::params {
  validate_bool($package_manage)
  validate_array($package_list)
  validate_string($package_ensure)

  file { 'corosync-config-dir' :
    ensure => 'directory',
    path   => '/etc/corosync',
    group  => 'root',
    owner  => 'root',
    mode   => '0755',
  }

  file { 'pacemaker-config-dir' :
    ensure => 'directory',
    path   => '/etc/pacemaker',
    group  => 'root',
    owner  => 'root',
    mode   => '0755',
  }

  if $package_manage {
    package { $package_list :
      ensure   => $package_ensure,
      provider => $package_provider,
    }
  }

}
