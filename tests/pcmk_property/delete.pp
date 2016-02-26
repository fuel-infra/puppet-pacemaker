pcmk_property { 'cluster-delay' :
  ensure => 'absent',
  value  =>  '50',
}

pcmk_property { 'batch-limit' :
  ensure => 'absent',
  value  =>  '50',
}
