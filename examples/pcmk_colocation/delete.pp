Pcmk_resource {
  ensure             => 'absent',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Pcmk_colocation {
  ensure => 'absent',
}

pcmk_resource { 'colocation-test1' :}

pcmk_resource { 'colocation-test2' :}

pcmk_colocation { 'colocation-test2_with_and_after_colocation-test1' :}

pcmk_resource { 'colocation-test3' :}

pcmk_colocation { 'colocation-test3_with_and_after_colocation-test1' :}

Pcmk_colocation<||> ->
Pcmk_resource<||>
