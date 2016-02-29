#!/bin/sh

show() {
  puppet resource pcmk_order "${1}"
  cibadmin --query --xpath "/cib/configuration/constraints/rsc_order[@id='${1}']"
  echo '--------------------'
}

show 'test2_after_test1'
