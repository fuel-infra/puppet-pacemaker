Pcmk_resource {
  ensure             => 'absent',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Pcmk_order {
  ensure => 'absent',
}

pcmk_resource { 'order-test1' :}

pcmk_resource { 'order-test2' :}

pcmk_order { 'order-test2_after_order-test1_score' :}

pcmk_order { 'order-test2_after_order-test1_kind' :}

Pcmk_order<||> ->
Pcmk_resource<||>
