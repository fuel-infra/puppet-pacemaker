Pcmk_resource {
  ensure             => 'absent',
  primitive_class    => 'ocf',
  primitive_provider => 'pacemaker',
  primitive_type     => 'Dummy',
}

pcmk_resource { 'test-simple1' :
  parameters => {
    'fake' => '1',
  },
}

pcmk_resource { 'test-simple2' :
  parameters => {
    'fake' => '2',
  },
}

pcmk_resource { 'test-simple-params1' :
  parameters => {
    'fake' => '3',
  },
  metadata   => {
    'migration-threshold' => '3',
    'failure-timeout'     => '120',
  },
  operations => {
    'monitor' => {
      'interval' => '20',
      'timeout'  => '10'
    },
    'start' => {
      'timeout' => '30'
    },
    'stop' => {
      'timeout' => '30'
    },
  }
}

pcmk_resource { 'test-simple-params2' :
  parameters => {
    'fake' => '4',
  },
  metadata   => {
    'migration-threshold' => '3',
    'failure-timeout'     => '120',
  },
  operations => [
    {
      'name' => 'monitor',
      'interval' => '10',
      'timeout'  => '10',
    },
    {
      'name' => 'monitor',
      'interval' => '60',
      'timeout'  => '10',
    },
    {
      'name' => 'start',
      'timeout' => '30',
    },
    {
      'name' => 'stop',
      'timeout' => '30',
    },
  ]
}

pcmk_resource { 'test-clone' :
  complex_type     => 'clone',
  complex_metadata => {
    'interleave' => 'true',
  },
  parameters       => {
    'fake' => '5',
  },
}

pcmk_resource { 'test-master' :
  primitive_type   => 'Stateful',
  complex_type     => 'master',
  complex_metadata => {
    'interleave' => 'true',
    'master-max' => '1',
  },
  parameters       => {
    'fake' => '6',
  },
}

# Remove fixtures for constraints
pcmk_resource { 'test1' :}
pcmk_resource { 'test2' :}
pcmk_resource { 'test3' :}
