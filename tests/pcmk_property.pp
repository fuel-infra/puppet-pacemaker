pcmk_property { 'cluster-delay' :
  ensure => 'present',
  value  =>  '50',
}

pcmk_property { 'batch-limit' :
  ensure => 'present',
  value  =>  '50',
}
