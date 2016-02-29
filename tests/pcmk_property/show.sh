#!/bin/sh

show() {
  puppet resource pcmk_property "${1}"
  cibadmin --query --xpath "/cib/configuration/crm_config/cluster_property_set/nvpair[@name='${1}']"
  echo '--------------------'
}

show 'cluster-delay'
show 'batch-limit'
