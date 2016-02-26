#!/bin/sh

show() {
  puppet resource pcmk_colocation "${1}"
  cibadmin --query --xpath "/cib/configuration/constraints/rsc_colocation[@id='${1}']"
  echo '--------------------'
}

show 'test2_with_and_after_test1'
show 'test3_with_and_after_test1'
