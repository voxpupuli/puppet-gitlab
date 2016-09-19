require 'spec_helper_acceptance'

describe 'gitlab class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'gitlab':
        external_url   => "http://${::fqdn}",
        service_manage => false,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    it 'should run reconfigure when config changes' do

      # gitlab-omnibus works differently in docker
      # Requires manual kick for beaker docker tests
      docker_workaround = <<-EOS
      exec { '/opt/gitlab/embedded/bin/runsvdir-start &':
        onlyif => '/bin/cat /proc/self/cgroup | grep docker'
      }
      EOS

      apply_manifest(docker_workaround, :catch_failures => true)

      start_service_pp = <<-EOS
      class { 'gitlab':
        external_url   => "http://${::fqdn}",
        gitlab_rails   => { 'time_zone' => 'GMT' }
      }
      EOS

      apply_manifest(start_service_pp, :catch_failures => true, :show_diff => true) do |r|
        expect(r.stdout).to match(/Scheduling refresh of Exec\[gitlab_reconfigure\]/)
      end
    end

    describe package('gitlab-ce') do
      it { is_expected.to be_installed }
    end

    context 'allows http connection on port 80' do
      describe command('curl 0.0.0.0:80/users/sign_in') do
        its(:stdout) { should match /reset_password_token/ }
      end
    end

  end
end
