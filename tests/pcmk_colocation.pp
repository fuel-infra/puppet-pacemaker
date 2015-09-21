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
  first  => 'test1',
  second => 'test2',
  score  => '200',
}

pcmk_resource { 'test3' :
  parameters => {
    'fake' => '3',
  },
}

pcmk_colocation { 'test3_with_and_after_test1' :
  first  => 'test1',
  second => 'test3',
  score  => '400',
}
