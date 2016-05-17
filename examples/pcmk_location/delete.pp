Pcmk_resource {
  ensure             => 'absent',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Pcmk_location {
  ensure => 'absent',
}

pcmk_resource { 'location-test1' :}

pcmk_location { 'location-test1_location_with_rule' :}

pcmk_location { 'location-test1_location_with_score' :}

Pcmk_location<||> ->
Pcmk_resource<||>
