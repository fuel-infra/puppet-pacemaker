Pcmk_resource {
  ensure             => 'present',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Service {
  ensure   => 'running',
  enable   => true,
  provider => 'pacemaker',
}

pcmk_resource { 'test1' :
  parameters => {
    'fake' => '1',
  },
}

service { 'test1' :}

Pcmk_resource <||> -> Service <||>
