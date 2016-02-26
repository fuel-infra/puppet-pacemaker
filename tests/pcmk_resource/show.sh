#!/bin/sh

show() {
  puppet resource pcmk_resource "${1}"
  cibadmin --query --xpath "/cib/configuration/resources/primitive[@id='${1}']"
  echo '--------------------'
}

show_clone() {
  puppet resource pcmk_resource "${1}"
  cibadmin --query --xpath "/cib/configuration/resources/clone[@id='clone_${1}']"
  echo '--------------------'
}

show_master() {
  puppet resource pcmk_resource "${1}"
  cibadmin --query --xpath "/cib/configuration/resources/master[@id='master_${1}']"
  echo '--------------------'
}

show 'test-simple1'
show 'test-simple2'
show 'test-simple-params1'
show 'test-simple-params2'
show_clone 'test-clone'
show_master 'test-master'
