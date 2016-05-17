require 'spec_helper'

describe 'pacemaker', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::params') }

        it { is_expected.to contain_class('pacemaker') }

        it { is_expected.to contain_class('pacemaker::firewall') }

        it { is_expected.to contain_class('pacemaker::install') }

        it { is_expected.to contain_class('pacemaker::setup') }

        it { is_expected.to contain_class('pacemaker::service') }
      end

    end
  end
end
