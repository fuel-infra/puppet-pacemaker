#!/bin/sh

show() {
  puppet resource pcmk_resource_default "${1}"
  cibadmin --query --xpath "/cib/configuration/rsc_defaults/meta_attributes/nvpair[@name='${1}']"
  echo '--------------------'
}

show 'resource-stickiness'
