Pcmk_resource {
  ensure             => 'present',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Pcmk_colocation {
  ensure => 'present',
}

pcmk_resource { 'colocation-test1' :
  parameters => {
    'fake' => '1',
  },
}

pcmk_resource { 'colocation-test2' :
  parameters => {
    'fake' => '2',
  },
}

pcmk_colocation { 'colocation-test2_with_and_after_colocation-test1' :
  first  => 'colocation-test1',
  second => 'colocation-test2',
  score  => '200',
}

pcmk_resource { 'colocation-test3' :
  parameters => {
    'fake' => '3',
  },
}

pcmk_colocation { 'colocation-test3_with_and_after_colocation-test1' :
  first  => 'colocation-test1',
  second => 'colocation-test3',
  score  => '400',
}

Pcmk_resource<||> ->
Pcmk_colocation<||>
