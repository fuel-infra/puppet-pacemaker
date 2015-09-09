require 'spec_helper'

describe Puppet::Type.type(:pcmk_commit).provider(:ruby) do

  let(:resource) { Puppet::Type.type(:pcmk_commit).new(
      :name => 'my_cib',
      :provider => :ruby,
    )
  }

  let(:provider) do
    resource.provider
  end

  before(:each) do
    puppet_debug_override
    provider.stubs(:cluster_debug_report).returns(true)
  end

  describe '#commit' do
    it 'should commit corresponding cib' do
      provider.stubs(:wait_for_online).returns(true)
      provider.expects(:crm_shadow).with('--force', '--commit', 'my_cib').returns(true)
      provider.sync 'my_cib'
    end
  end

end

