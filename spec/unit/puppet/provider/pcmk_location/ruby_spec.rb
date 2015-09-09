require 'spec_helper'

describe Puppet::Type.type(:pcmk_location).provider(:ruby) do

  let(:resource) do
    Puppet::Type.type(:pcmk_location).new(
        :name => 'my_location',
        :ensure => :present,
        :primitive => 'my_primitive',
        :node => 'my_node',
        :provider => :ruby,
        :score => '200',
    )
  end

  let(:provider) do
    resource.provider
  end

  before(:each) do
    puppet_debug_override
    provider.stubs(:cluster_debug_report).returns(true)
  end

  context '#create' do

    it 'should create a simple location' do
      xml = <<-eos
<rsc_location id='my_location' node='my_node' rsc='my_primitive' score='200'/>
      eos
      provider.expects(:cibadmin_create).with xml, 'constraints'
      provider.create
      provider.flush
    end

    it 'should create location with rule' do
      resource.delete :node
      resource.delete :score
      resource[:rules] = [
          {
              :score => 'inf',
              :expressions => [
                  {
                      :attribute => 'pingd1',
                      :operation => 'defined',
                  },
                  {
                      :attribute => 'pingd2',
                      :operation => 'defined',
                  }
              ]
          }
      ]

      xml = <<-eos
<rsc_location id='my_location' rsc='my_primitive'>
  <rule boolean-op='or' id='my_location-rule-0' score='INFINITY'>
    <expression attribute='pingd1' id='my_location-rule-0-expression-0' operation='defined'/>
    <expression attribute='pingd2' id='my_location-rule-0-expression-1' operation='defined'/>
  </rule>
</rsc_location>
      eos

      provider.expects(:cibadmin_create).with xml, 'constraints'
      provider.create
      provider.flush
    end

    it 'should create location with several rules' do
      resource.delete :node
      resource.delete :score
      resource[:rules] = [
          {
              :score => 'inf',
              :expressions => [
                  {
                      :attribute => 'pingd1',
                      :operation => 'defined',
                  }
              ]
          },
          {
              :score => 'inf',
              :expressions => [
                  {
                      :attribute => 'pingd2',
                      :operation => 'defined',
                  }
              ]
          }
      ]

      xml = <<-eos
<rsc_location id='my_location' rsc='my_primitive'>
  <rule boolean-op='or' id='my_location-rule-0' score='INFINITY'>
    <expression attribute='pingd1' id='my_location-rule-0-expression-0' operation='defined'/>
  </rule>
  <rule boolean-op='or' id='my_location-rule-1' score='INFINITY'>
    <expression attribute='pingd2' id='my_location-rule-1-expression-0' operation='defined'/>
  </rule>
</rsc_location>
      eos
      provider.expects(:cibadmin_create).with xml, 'constraints'
      provider.create
      provider.flush
    end

  end

  context '#update' do
      it 'should update a simple location' do
        xml = <<-eos
<rsc_location id='my_location' node='my_node' rsc='my_primitive' score='200'/>
        eos
        provider.expects(:cibadmin_modify).with xml, 'constraints'
        provider.create
        provider.property_hash[:ensure] = :present
        provider.flush
      end
  end

  context '#exists' do

    it 'detects an existing location' do
      provider.stubs(:constraint_locations).returns(
          {
              'my_location' => {
                  'rsc' => 'my_resource',
                  'node' => 'my_node',
                  'score' => '100',
              }
          }
      )
      expect(provider.exists?).to be_truthy
      provider.stubs(:constraint_locations).returns(
          {
              'other_location' => {
                  'rsc' => 'other_resource',
                  'node' => 'other_node',
                  'score' => '100',
              }
          }
      )
      expect(provider.exists?).to be_falsey
      provider.stubs(:constraint_locations).returns({})
      expect(provider.exists?).to be_falsey
    end

    it 'loads the current resource state' do
      provider.stubs(:constraint_locations).returns(
          {
              'my_location' => {
                  'rsc' => 'my_resource',
                  'node' => 'my_node',
                  'score' => '100',
              }
          }
      )
      provider.exists?
      expect(provider.primitive).to eq('my_resource')
      expect(provider.node).to eq('my_node')
      expect(provider.score).to eq('100')
    end

  end

  context '#destroy' do
    it 'can remove a location' do
      provider.expects(:cibadmin_delete).with "<rsc_location id='my_location'/>", 'constraints'
      provider.destroy
    end
  end
end
