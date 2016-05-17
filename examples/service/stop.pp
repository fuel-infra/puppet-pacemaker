# Using the wrapper

# a simple service
service { 'service-test1' :
  ensure => 'stopped',
  enable => true,
}

# apply a wrapper
pacemaker::wrapper { 'service-test1' :
  primitive_class    => 'ocf',
  primitive_provider => 'pacemaker',
  primitive_type     => 'Dummy',

  parameters => {
    'fake' => '1',
  },

  operations => {
    'monitor' => {
      'interval' => '10',
      'timeout' => '10',
    },
  },
}

# Without the wrapper

pcmk_resource { 'service-test2' :
  ensure             => 'present',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
  parameters => {
    'fake' => '2',
  },
  operations => {
    'monitor' => {
      'interval' => '10',
      'timeout' => '10',
    },
  },
}

service { 'service-test2' :
  ensure   => 'stopped',
  enable   => true,
  provider => 'pcmk_xml',
}

Pcmk_resource['service-test2'] ->
Service['service-test2']
