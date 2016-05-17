require 'spec_helper'

describe 'pacemaker::setup', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::params') }

        it { is_expected.to contain_class('pacemaker::setup') }

        it { is_expected.to contain_class('pacemaker::setup::auth_key') }

        if facts[:osfamily] == 'Debian'
          it { is_expected.to contain_class('pacemaker::setup::debian') }
        end

        release = facts[:operatingsystemrelease].split('.')
        major = release.first
        minor = release.last

        if facts[:osfamily] == 'RedHat' and ( (major == '7') or (minor == '6' and major.to_i >= 6) )
          it { is_expected.to contain_class('pacemaker::setup::pcsd') }
        else
          it { is_expected.to contain_class('pacemaker::setup::config') }
        end

      end

    end
  end
end
