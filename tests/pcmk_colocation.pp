Pcmk_resource {
  ensure             => 'present',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
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

pcmk_colocation { 'test2_with_and_after_test1' :
  first  => 'test2',
  second => 'test1',
  score  => '200',
}
