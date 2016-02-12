# Caveats:
#   Duplicates the fact spec test 'systemd_spec' from camptocamp/puppet-systemd
#
require 'spec_helper'

describe Facter::Util::Fact do
  before { Facter.clear }

  describe 'systemd' do
    context 'returns true when systemd present' do
      before do
        Facter.fact(:kernel).stubs(:value).returns(:linux)
      end
      let(:facts) { { kernel: :linux } }

      it do
        Facter::Util::Resolution.expects(:exec).with('ps -p 1 -o comm=').returns('systemd')
        expect(Facter.value(:gitlab_systemd)).to eq(true)
      end
    end
    context 'returns false when systemd not present' do
      before do
        Facter.fact(:kernel).stubs(:value).returns(:linux)
      end
      let(:facts) { { kernel: :linux } }

      it do
        Facter::Util::Resolution.expects(:exec).with('ps -p 1 -o comm=').returns('init')
        expect(Facter.value(:gitlab_systemd)).to eq(false)
      end
    end

    context 'returns nil when kernel is not linux' do
      before do
        Facter.fact(:kernel).stubs(:value).returns(:windows)
      end
      let(:facts) { { kernel: :windows } }

      it do
        Facter::Util::Resolution.expects(:exec).with('ps -p 1 -o comm=').never
        expect(Facter.value(:gitlab_systemd)).to be_nil
      end
    end
  end
end
