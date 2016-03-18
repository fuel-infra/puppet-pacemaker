require 'spec_helper'

describe Puppet::Type.type(:pcmk_operation_default).provider(:xml) do

  let(:operation) { Puppet::Type.type(:pcmk_operation_default).new(
      :name => 'my_default',
      :value => 'my_value',
      :provider => :xml,
  )}

  let(:provider) do
    operation.provider
  end

  before(:each) do
    puppet_debug_override
  end

  describe '#exists?' do
    it 'should determine if the rsc_default is defined' do
      provider.expects(:operation_default_defined?).with('my_default')
      provider.exists?
    end
  end

  describe '#create' do
    it 'should create operation default with corresponding value' do
      provider.expects(:operation_default_set).with('my_default', 'my_value')
      provider.create
    end
  end

  describe '#update' do
    it 'should update operation default with corresponding value' do
      provider.expects(:operation_default_set).with('my_default', 'my_value')
      provider.create
    end
  end

  describe '#destroy' do
    it 'should destroy operation default with corresponding name' do
      provider.expects(:operation_default_delete).with('my_default')
      provider.destroy
    end
  end

end
