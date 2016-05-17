Pcmk_resource {
  ensure             => 'absent',
  primitive_class    => 'ocf',
  primitive_provider => 'pacemaker',
  primitive_type     => 'Dummy',
}

pcmk_resource { 'test-simple1' :}

pcmk_resource { 'test-simple2' :}

pcmk_resource { 'test-simple-params1' :}

pcmk_resource { 'test-simple-params2' :}

pcmk_resource { 'test-clone' :}

pcmk_resource { 'test-master' :}

pcmk_resource { 'test-clone-change' :}

pcmk_resource { 'test-master-change' :}
