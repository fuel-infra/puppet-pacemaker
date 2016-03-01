# puppet-pacemaker module

This Puppet module can work with the running Pacemaker cluster to manage its
configuration. It can create, update and remove most of the configuration
objects and query their status.

The interface of these Puppet types is loosely based on **puppetlabs/corosync**
with *cs_* prefix changed to *pcmk_* but it's not entirely compatible.

**puppet-pacemaker** is much more sophisticated then **puppetlabs/corosync** and
provides a lot of debugging features, checks, configuration and it can work
even when the Puppet is being run on many cluster nodes at the same time.
