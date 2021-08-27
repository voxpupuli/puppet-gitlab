require 'spec_helper_acceptance'

describe 'gitlab class' do
  context 'default parameters' do
    it 'idempotently with no errors' do
      pp = <<-EOS
      class { 'gitlab':
        external_url => "http://${::fqdn}",
      }
      EOS

      result = apply_manifest(pp, catch_failures: true)

      # gitlab-ctl reconfigure emits a warning if the LD_LIBRARY_PATH
      # is set, even if it is empty.
      expect(result.stdout).not_to match(%r{LD_LIBRARY_PATH was found})

      apply_manifest(pp, catch_changes: true)

      shell('sleep 15') # give it some time to start up
    end

    describe package('gitlab-ce') do
      it { is_expected.to be_installed }
    end

    describe file('/etc/gitlab/initial_root_password') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match %r{^Password: ...................} }
    end

    describe command('curl -s -S http://127.0.0.1:80/users/sign_in') do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match %r{.*<div id="signin-container">.*} }
    end
  end
end
