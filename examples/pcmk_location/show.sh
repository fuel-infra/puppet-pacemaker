#!/bin/sh

show() {
  puppet resource pcmk_location "${1}"
  cibadmin --query --xpath "/cib/configuration/constraints/rsc_location[@id='${1}']"
  echo '--------------------'
}

show 'location-test1_location_with_rule'
show 'location-test1_location_with_score'
