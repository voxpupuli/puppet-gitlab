require 'spec_helper_acceptance'

describe 'gitlab class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'gitlab':
        external_url => "http://${::fqdn}",
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('gitlab-ce') do
      it { is_expected.to be_installed }
    end


    it 'allows http connection on port 8080' do
      shell 'sleep 15' # give it some time to start up
      describe command('curl 0.0.0.0:80/users/sign_in') do
        its(:stdout) { should match /GitLab|password/ }
      end
    end

  end
end
