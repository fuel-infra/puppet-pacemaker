require 'spec_helper_acceptance'
require_relative '../../lib/serverspec/type/pcmk_property'

describe 'pcmk_property' do
  context 'create' do
    include_examples 'manifest', example_manifest('pcmk_property/create.pp')

    describe pcmk_property('cluster-delay') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '50' }
    end

    describe pcmk_property('batch-limit') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '50' }
    end
  end

  context 'update' do
    include_examples 'manifest', example_manifest('pcmk_property/update.pp')

    describe pcmk_property('cluster-delay') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '51' }
    end

    describe pcmk_property('batch-limit') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '51' }
    end
  end

  context 'delete' do
    include_examples 'manifest', example_manifest('pcmk_property/delete.pp')

    describe pcmk_property('cluster-delay') do
      it { is_expected.not_to be_present }
    end

    describe pcmk_property('batch-limit') do
      it { is_expected.not_to be_present }
    end
  end
end
