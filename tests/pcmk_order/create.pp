Pcmk_resource {
  ensure             => 'present',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Pcmk_order {
  ensure => 'present',
}

pcmk_resource { 'test1' :
  parameters => {
    'fake' => '1',
  },
}

pcmk_resource { 'test2' :
  parameters => {
    'fake' => '2',
  },
}

pcmk_order { 'test2_after_test1' :
  first  => 'test1',
  second => 'test2',
  score  => '200',
}
