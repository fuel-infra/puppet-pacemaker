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

$rules = [
  {
    'score' => '100',
    'expressions' => [
      {
        'attribute' => 'test1',
        'operation' => 'defined',
      }
    ]
  },
  {
    'score' => '200',
    'expressions' => [
      {
        'attribute' => 'test2',
        'operation' => 'defined',
      }
    ]
  }
]

pcmk_location { 'test1_location_with_rule' :
  primitive => 'test1',
  rules     => $rules,
}

pcmk_location { 'test1_location_with_score' :
  primitive  => 'test1',
  node       => $pcmk_node_name,
  score      => '200',
}
