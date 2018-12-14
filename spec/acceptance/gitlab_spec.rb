require 'spec_helper_acceptance'

describe 'gitlab class' do
  context 'default parameters' do
    it 'idempotently with no errors' do
      pp = <<-EOS
      class { 'gitlab':
        external_url => "http://${::fqdn}",
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)

      shell('sleep 15') # give it some time to start up
    end

    describe package('gitlab-ce') do
      it { is_expected.to be_installed }
    end

    describe command('curl -s -S http://127.0.0.1:80/users/sign_in') do
      its(:stdout) { is_expected.to match %r{.*reset_password_token=.*redirected.*} }
    end
  end
end
