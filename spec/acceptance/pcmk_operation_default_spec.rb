require 'spec_helper_acceptance'
require_relative '../../lib/serverspec/type/pcmk_operation_default'

describe 'pcmk_operation_default' do
  context 'create' do
    include_examples 'manifest', example_manifest('pcmk_operation_default/create.pp')

    describe pcmk_operation_default('interval') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '300' }
    end
  end

  context 'update' do
    include_examples 'manifest', example_manifest('pcmk_operation_default/update.pp')

    describe pcmk_operation_default('interval') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '301' }
    end
  end

  context 'delete' do
    include_examples 'manifest', example_manifest('pcmk_operation_default/delete.pp')

    describe pcmk_operation_default('interval') do
      it { is_expected.not_to be_present }
    end
  end
end
