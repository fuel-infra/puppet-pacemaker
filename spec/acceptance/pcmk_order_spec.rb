require 'spec_helper_acceptance'
require_relative '../../lib/serverspec/type/pcmk_order'
require_relative '../../lib/serverspec/type/pcmk_resource'

describe 'pcmk_order' do
  context 'create' do
    include_examples 'manifest', example_manifest('pcmk_order/create.pp')

    describe pcmk_order('order-test2_after_order-test1_score') do
      it { is_expected.to be_present }
      its(:first) { is_expected.to eq 'order-test1' }
      its(:second) { is_expected.to eq 'order-test2' }
      its(:score) { is_expected.to eq '200' }
    end

    describe pcmk_order('order-test2_after_order-test1_kind') do
      it { is_expected.to be_present }
      its(:first) { is_expected.to eq 'order-test1' }
      its(:second) { is_expected.to eq 'order-test2' }
      its(:score) { is_expected.to be_nil }
      its(:first_action) { is_expected.to eq 'promote' }
      its(:second_action) { is_expected.to eq 'demote' }
      its(:kind) { is_expected.to eq 'mandatory' }
      its(:symmetrical) { is_expected.to eq 'true' }
    end

    describe pcmk_resource('order-test1') do
      it { is_expected.to be_present }
    end

    describe pcmk_resource('order-test2') do
      it { is_expected.to be_present }
    end
  end

  context 'update' do
    include_examples 'manifest', example_manifest('pcmk_order/update.pp')

    describe pcmk_order('order-test2_after_order-test1_score') do
      it { is_expected.to be_present }
      its(:first) { is_expected.to eq 'order-test1' }
      its(:second) { is_expected.to eq 'order-test2' }
      its(:score) { is_expected.to eq '201' }
    end

    describe pcmk_order('order-test2_after_order-test1_kind') do
      it { is_expected.to be_present }
      its(:first) { is_expected.to eq 'order-test1' }
      its(:second) { is_expected.to eq 'order-test2' }
      its(:score) { is_expected.to be_nil }
      its(:first_action) { is_expected.to eq 'promote' }
      its(:second_action) { is_expected.to eq 'start' }
      its(:kind) { is_expected.to eq 'serialize' }
      its(:symmetrical) { is_expected.to eq 'true' }
    end

    describe pcmk_resource('order-test1') do
      it { is_expected.to be_present }
    end

    describe pcmk_resource('order-test2') do
      it { is_expected.to be_present }
    end
  end

  context 'delete' do
    include_examples 'manifest', example_manifest('pcmk_order/delete.pp')

    describe pcmk_order('order-test2_after_order-test1_score') do
      it { is_expected.not_to be_present }
    end

    describe pcmk_order('order-test2_after_order-test1_kind') do
      it { is_expected.not_to be_present }
    end

    describe pcmk_resource('order-test1') do
      it { is_expected.not_to be_present }
    end

    describe pcmk_resource('order-test2') do
      it { is_expected.not_to be_present }
    end
  end
end
