Pcmk_resource {
  ensure             => 'present',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Pcmk_location {
  ensure => 'present',
}

pcmk_resource { 'location-test1' :
  parameters => {
    'fake' => '1',
  },
}

$rules = [
  {
    'score' => '100',
    'expressions' => [
      {
        'attribute' => 'a',
        'operation' => 'defined',
      },
    ]
  },
  {
    'score' => '200',
    'expressions' => [
      {
        'attribute' => 'b',
        'operation' => 'defined',
      },
    ]
  }
]

pcmk_location { 'location-test1_location_with_rule' :
  primitive => 'location-test1',
  rules     => $rules,
}

pcmk_location { 'location-test1_location_with_score' :
  primitive => 'location-test1',
  node      => $pcmk_node_name,
  score     => '200',
}

Pcmk_resource<||> ->
Pcmk_location<||>
