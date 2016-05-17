Pcmk_resource {
  ensure             => 'present',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Pcmk_order {
  ensure => 'present',
}

pcmk_resource { 'order-test1' :
  parameters => {
    'fake' => '1',
  },
}

pcmk_resource { 'order-test2' :
  parameters => {
    'fake' => '2',
  },
}

pcmk_order { 'order-test2_after_order-test1_score' :
  first  => 'order-test1',
  second => 'order-test2',
  score  => '200',
}

# Pacemaker 1.1+
pcmk_order { 'order-test2_after_order-test1_kind' :
  first         => 'order-test1',
  first_action  => 'promote',
  second        => 'order-test2',
  second_action => 'demote',
  kind          => 'mandatory',
  symmetrical   => true,
}

Pcmk_resource<||> ->
Pcmk_order<||>
