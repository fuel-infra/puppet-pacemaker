require 'spec_helper_acceptance'
require_relative '../../lib/serverspec/type/pcmk_resource_default'

describe 'pcmk_resource_default' do
  context 'create' do
    include_examples 'manifest', example_manifest('pcmk_resource_default/create.pp')

    describe pcmk_resource_default('resource-stickiness') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '100' }
    end
  end

  context 'update' do
    include_examples 'manifest', example_manifest('pcmk_resource_default/update.pp')

    describe pcmk_resource_default('resource-stickiness') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '101' }
    end
  end

  context 'delete' do
    include_examples 'manifest', example_manifest('pcmk_resource_default/delete.pp')

    describe pcmk_resource_default('resource-stickiness') do
      it { is_expected.not_to be_present }
    end
  end
end
