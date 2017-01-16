require 'spec_helper'

describe Puppet::Type.type(:service).provider(:pacemaker) do

  let(:resource) { Puppet::Type.type(:service).new(
      :name => title,
      :provider=> :pacemaker,
    )
  }

  let(:provider) do
    resource.provider
  end

  let(:title) { 'myservice' }
  let(:full_name) { 'clone-p_myservice' }
  let(:name) { 'p_myservice' }
  let(:hostname) { 'mynode' }
  let(:primitive_class) { 'ocf' }

  before :each do
    puppet_debug_override
    provider.stubs(:title).returns(title)
    provider.stubs(:hostname).returns(hostname)
    provider.stubs(:name).returns(name)
    provider.stubs(:full_name).returns(full_name)
    provider.stubs(:basic_service_name).returns(title)
    provider.stubs(:primitive_class).returns(primitive_class)

    provider.stubs(:cib_reset).returns(true)

    provider.stubs(:wait_for_online).returns(true)
    provider.stubs(:wait_for_status).returns(true)
    provider.stubs(:wait_for_start).returns(true)
    provider.stubs(:wait_for_stop).returns(true)

    provider.stubs(:disable_basic_service).returns(true)
    provider.stubs(:get_primitive_puppet_status).returns(:running)
    provider.stubs(:get_primitive_puppet_enable).returns(:true)
    provider.stubs(:service_location_exists?).returns(true)

    provider.stubs(:primitive_is_managed?).returns(true)
    provider.stubs(:primitive_is_running?).returns(true)
    provider.stubs(:primitive_has_failures?).returns(false)
    provider.stubs(:primitive_is_complex?).returns(false)
    provider.stubs(:primitive_is_multistate?).returns(false)
    provider.stubs(:primitive_is_clone?).returns(false)

    provider.stubs(:unban_primitive).returns(true)
    provider.stubs(:ban_primitive).returns(true)
    provider.stubs(:start_primitive).returns(true)
    provider.stubs(:stop_primitive).returns(true)
    provider.stubs(:cleanup_primitive).returns(true)
    provider.stubs(:enable).returns(true)
    provider.stubs(:disable).returns(true)

    provider.stubs(:constraint_location_add).returns(true)
    provider.stubs(:constraint_location_remove).returns(true)

    provider.stubs(:cluster_debug_report).returns('')
  end

  context 'service name mangling' do
    it 'uses title as the service name if it is found in CIB' do
      provider.unstub(:name)
      provider.stubs(:primitive_exists?).with(title).returns(true)
      expect(provider.name).to eq(title)
    end

    it 'can generate a list of service name variations' do
      variations = provider.service_name_variations 'test'
      expect(variations).to eq %w(test p_test)
      variations = provider.service_name_variations 'p_test'
      expect(variations).to eq %w(p_test test)
      variations = provider.service_name_variations 'clone-test'
      expect(variations).to eq %w(clone-test p_clone-test test p_test)
    end

    it 'can find an existing primitive name in the list' do
      provider.expects(:primitive_exists?).with('a').returns(false)
      provider.expects(:primitive_exists?).with('b').returns(true)
      provider.expects(:primitive_exists?).with('c').never
      expect(provider.pick_existing_name %w(a b c)).to eq 'b'
    end

    it 'uses "p_" prefix with name if found name with prefix' do
      provider.unstub(:name)
      provider.stubs(:primitive_exists?).with(title).returns(false)
      provider.stubs(:primitive_exists?).with(name).returns(true)
      expect(provider.name).to eq(name)
    end

    it 'uses name without "p_" to disable basic service' do
      provider.unstub(:basic_service_name)
      expect(provider.basic_service_name).to eq(title)
    end

    it 'uses "name" as the basic service name if "name" is provided' do
      provider.unstub(:basic_service_name)
      provider.stubs(:service_title).returns('wrong_title')
      provider.stubs(:service_name).returns('system_name')
      expect(provider.basic_service_name).to eq('system_name')
    end

    it 'can work with complex name instead of simple' do
      provider.unstub(:name)
      provider.stubs(:service_title).returns(full_name)
      provider.stubs(:service_name).returns(name)
      provider.stubs(:primitive_exists?).with('p_' + full_name).returns(false)
      provider.stubs(:primitive_exists?).with(full_name).returns(false)
      provider.stubs(:primitive_exists?).with(name).returns(true)
      expect(provider.name).to eq(name)
    end

    it 'can find a service by provided name if the title is wrong' do
      provider.unstub(:name)
      provider.stubs(:service_title).returns('wrong_title')
      provider.stubs(:service_name).returns(name)
      provider.stubs(:primitive_exists?).with(name).returns(true)
      provider.stubs(:primitive_exists?).with('wrong_title').returns(false)
      provider.stubs(:primitive_exists?).with('p_wrong_title').returns(false)
      expect(provider.name).to eq(name)
    end
  end

  context '#status' do
    it 'should return the correct status values' do
      provider.stubs(:primitive_is_running?).returns(true)
      provider.unstub(:get_primitive_puppet_status)
      expect(provider.status).to eq :running
      provider.stubs(:primitive_is_running?).returns(false)
      expect(provider.status).to eq :stopped
    end

    it 'should reset cib mnemoization on every call' do
      provider.expects(:cib_reset)
      provider.status
    end

    it 'gets service status globally for a simple service' do
      provider.expects(:get_primitive_puppet_status).with name
      provider.status
    end

    it 'gets service status locally for a clone service' do
      provider.stubs(:primitive_is_complex?).returns(true)
      provider.stubs(:primitive_is_multistate?).returns(false)
      provider.stubs(:primitive_is_clone?).returns(true)
      provider.expects(:get_primitive_puppet_status).with name, hostname
      provider.status
    end

    it 'gets service status locally for a multistate service' do
      provider.stubs(:primitive_is_complex?).returns(true)
      provider.stubs(:primitive_is_multistate?).returns(true)
      provider.stubs(:primitive_is_clone?).returns(false)
      provider.expects(:get_primitive_puppet_status).with name, hostname
      provider.status
    end

    it 'counts a service as stopped if location constraint is missing' do
      provider.stubs(:get_primitive_puppet_status).returns(:running)
      provider.stubs(:service_location_exists?).returns(false)
      expect(provider.status).to eq :stopped
      provider.stubs(:service_location_exists?).returns(true)
      expect(provider.status).to eq :running
    end

    it 'counts a service as stopped if the primitive has failures' do
      provider.stubs(:get_primitive_puppet_status).returns(:running)
      provider.stubs(:service_location_exists?).returns(true)
      provider.expects(:primitive_has_failures?).with(name, hostname).returns(true)
      expect(provider.status).to eq :stopped
      provider.expects(:primitive_has_failures?).with(name, hostname).returns(false)
      expect(provider.status).to eq :running
    end

  end

  context '#start' do
    it 'tries to enable service if it is not enabled to work with it' do
      provider.stubs(:primitive_is_managed?).returns(false)
      provider.expects(:enable).once
      provider.start
      provider.stubs(:primitive_is_managed?).returns(true)
      provider.unstub(:enable)
      provider.expects(:enable).never
      provider.start
    end

    it 'tries to disable a basic service with the same name' do
      provider.expects(:disable_basic_service)
      provider.start
    end

    it 'should cleanup a primitive' do
      provider.stubs(:primitive_has_failures?).returns(true)
      provider.expects(:cleanup_primitive).with(full_name, hostname).once
      provider.start
    end

    it 'tries to unban the service on the node by the name' do
      provider.expects(:unban_primitive).with(name, hostname)
      provider.start
    end

    it 'tries to start the service by its full name' do
      provider.expects(:start_primitive).with(full_name)
      provider.start
    end

    it 'adds a location constraint for the service by its full_name' do
      provider.stubs(:service_location_exists?).returns(false)
      provider.expects(:service_location_add).with(full_name, hostname)
      provider.start
    end

    it 'waits for the service to start anywhere if primitive is clone' do
      provider.stubs(:primitive_is_clone?).returns(true)
      provider.stubs(:primitive_is_multistate?).returns(false)
      provider.stubs(:primitive_is_complex?).returns(true)
      provider.expects(:wait_for_start).with name
      provider.start
    end

    it 'waits for the service to start master anywhere if primitive is multistate' do
      provider.stubs(:primitive_is_clone?).returns(false)
      provider.stubs(:primitive_is_multistate?).returns(true)
      provider.stubs(:primitive_is_complex?).returns(true)
      provider.expects(:wait_for_master).with name
      provider.start
    end

    it 'waits for the service to start anywhere if primitive is simple' do
      provider.stubs(:primitive_is_clone?).returns(false)
      provider.stubs(:primitive_is_multistate?).returns(false)
      provider.stubs(:primitive_is_complex?).returns(false)
      provider.expects(:wait_for_start).with name
      provider.start
    end
  end

  context '#stop' do
    it 'tries to disable service if it is not enabled to work with it' do
      provider.stubs(:primitive_is_managed?).returns(false)
      provider.expects(:enable).once
      provider.stop
      provider.stubs(:primitive_is_managed?).returns(true)
      provider.unstub(:enable)
      provider.expects(:enable).never
      provider.stop
    end

    it 'should cleanup a primitive on stop' do
      provider.stubs(:primitive_has_failures?).returns(true)
      provider.expects(:cleanup_primitive).with(full_name, hostname).once
      provider.stop
    end

    it 'uses Ban to stop the service and waits for it to stop locally if service is clone' do
      provider.stubs(:primitive_is_complex?).returns(true)
      provider.stubs(:primitive_is_clone?).returns(true)
      provider.stubs(:primitive_is_multistate?).returns(false)
      provider.expects(:wait_for_stop).with name, hostname
      provider.expects(:ban_primitive).with name, hostname
      provider.stop
    end

    it 'uses Ban to stop the service and waits for it to stop locally if service is multistate' do
      provider.stubs(:primitive_is_complex?).returns(true)
      provider.stubs(:primitive_is_clone?).returns(false)
      provider.stubs(:primitive_is_multistate?).returns(true)
      provider.expects(:wait_for_stop).with name, hostname
      provider.expects(:ban_primitive).with name, hostname
      provider.stop
    end

    it 'uses Stop to stop the service and waits for it to stop globally if service is simple' do
      provider.stubs(:primitive_is_complex?).returns(false)
      provider.expects(:wait_for_stop).with name
      provider.expects(:stop_primitive).with name
      provider.stop
    end
  end

  context '#restart' do
    it 'does not stop or start the service if it is not locally running' do
      provider.stubs(:primitive_is_running?).with(name, hostname).returns(false)
      provider.unstub(:stop)
      provider.unstub(:start)
      provider.expects(:stop).never
      provider.expects(:start).never
      provider.restart
    end

    it 'stops and start the service if it is locally running' do
      provider.stubs(:primitive_is_running?).with(name, hostname).returns(true)
      restart_sequence = sequence('restart')
      provider.expects(:stop).in_sequence(restart_sequence)
      provider.expects(:start).in_sequence(restart_sequence)
      provider.restart
    end
  end

  context 'basic service handling' do
    before :each do
      provider.unstub(:disable_basic_service)
      provider.suitable_providers = [:base, :service]
      provider.extra_providers.each do |extra_provider|
        extra_provider.stubs(:enableable?).returns true
        extra_provider.stubs(:enabled?).returns :true
        extra_provider.stubs(:disable).returns true
        extra_provider.stubs(:stop).returns true
        extra_provider.stubs(:status).returns :running
      end
    end

    it 'tries to disable the basic service if it is enabled' do
      provider.extra_providers.first.expects(:disable).once
      provider.extra_providers.last.expects(:disable).once
      provider.disable_basic_service
    end

    it 'tries to stop the service if it is running' do
      provider.extra_providers.first.expects(:stop).once
      provider.extra_providers.last.expects(:stop).once
      provider.disable_basic_service
    end

    it 'does not try to stop a systemd running service' do
      provider.stubs(:primitive_class).returns('systemd')
      provider.extra_providers.first.unstub(:stop)
      provider.extra_providers.last.unstub(:stop)
      provider.extra_providers.first.expects(:stop).never
      provider.extra_providers.last.expects(:stop).never
      provider.disable_basic_service
    end

    it 'stops an ocf based service' do
      provider.stubs(:primitive_class).returns('ocf')
      provider.extra_providers.first.expects(:stop).once
      provider.extra_providers.last.expects(:stop).once
      provider.disable_basic_service
    end
  end

end
