require 'spec_helper'

describe 'gitlab' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "gitlab class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('gitlab::params') }
        it { is_expected.to contain_class('gitlab::install').that_comes_before('gitlab::config') }
        it { is_expected.to contain_class('gitlab::config') }
        it { is_expected.to contain_class('gitlab::service').that_subscribes_to('gitlab::config') }

        it { is_expected.to contain_service('gitlab') }
        it { is_expected.to contain_package('gitlab').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'gitlab class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('gitlab') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
