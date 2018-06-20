require 'spec_helper'

describe 'gitlab::cirunner::docker_ssh' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'gitlab::cirunner::docker_ssh.example.com' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      # manage_docker: true,
      # xz_package_name: "xz-utils",
      # default_image: "ubuntu_trusty",
      # docker_images: {},
      # runners: {},
      # default_coordinator: :undef,
      # default_run_untagged: :undef,
      # default_locked: :undef,
      # default_tags: :undef,
      # default_host: :undef,
      # default_cert_path: :undef,
      # default_tlsverify: :undef,
      # default_hostname: :undef,
      # default_cpuset_cpus: :undef,
      # default_cpus: :undef,
      # default_dns: :undef,
      # default_dns_search: :undef,
      # default_privileged: :undef,
      # default_userns: :undef,
      # default_cap_add: :undef,
      # default_cap_drop: :undef,
      # default_security_opt: :undef,
      # default_devices: :undef,
      # default_disable_cache: :undef,
      # default_volumes: :undef,
      # default_volume_driver: :undef,
      # default_cache_dir: :undef,
      # default_extra_hosts: :undef,
      # default_volumes_from: :undef,
      # default_network_mode: :undef,
      # default_links: :undef,
      # default_services: :undef,
      # default_wait_for_services_timeout: :undef,
      # default_allowed_images: :undef,
      # default_allowed_services: :undef,
      # default_pull_policy: :undef,
      # default_shm_size: :undef,
      # default_ssh_user: :undef,
      # default_ssh_password: :undef,
      # default_ssh_host: :undef,
      # default_ssh_port: :undef,
      # default_ssh_identity_file: :undef,

    }
  end

  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }

  test_on = {
    hardwaremodels: ['x86_64'],
    supported_os: [
      {
        'operatingsystem'        => 'Debian',
        'operatingsystemrelease' => ['7']
      }
    ]
  }
  on_supported_os(test_on).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('xz-utils') }
        it do
          is_expected.to contain_class('docker::images').with(
            images: {
              'ubuntu_trusty' => {
                'image' => 'ubuntu',
                'image_tag' => 'trusty'
              }
            }
          )
        end
      end
      describe 'Change Defaults' do
        context 'manage_docker' do
          before { params.merge!(manage_docker: false) }
          it { is_expected.to compile }
          it { is_expected.not_to contain_class('::docker::images') }
        end
        context 'xz_package_name' do
          before { params.merge!(xz_package_name: 'foobar') }
          it { is_expected.to compile }
          it { is_expected.to contain_package('foobar') }
        end
        context 'docker_images' do
          before do
            params.merge!(
              docker_images: {
                'ubuntu_trusty' => {
                  'image' => 'ubuntu',
                  'image_tag' => 'trusty'
                },
                'ubuntu_xenial' => {
                  'image' => 'ubuntu',
                  'image_tag' => 'xenial'
                }
              }
            )
          end
          it { is_expected.to compile }
          it do
            is_expected.to contain_class('docker::images').with(
              images: {
                'ubuntu_trusty' => {
                  'image' => 'ubuntu',
                  'image_tag' => 'trusty'
                },
                'ubuntu_xenial' => {
                  'image' => 'ubuntu',
                  'image_tag' => 'xenial'
                }
              }
            )
          end
        end
      end
      describe 'check bad type' do
        context 'manage_docker' do
          before { params.merge!(manage_docker: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'xz_package_name' do
          before { params.merge!(xz_package_name: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_image' do
          before { params.merge!(default_image: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_image' do
          before do
            params.merge!(
              default_image: 'foobar',
              docker_images: { 'bla' => {} }
            )
          end
          it do
            is_expected.to raise_error(
              Puppet::Error,
              %r{Docker not configuered with default image: foobar}
            )
          end
        end
        context 'docker_images' do
          before { params.merge!(docker_images: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'runners' do
          before { params.merge!(runners: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_coordinator' do
          before { params.merge!(default_coordinator: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_run_untagged' do
          before { params.merge!(default_run_untagged: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_locked' do
          before { params.merge!(default_locked: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_tags' do
          before { params.merge!(default_tags: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_host' do
          before { params.merge!(default_host: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_cert_path' do
          before { params.merge!(default_cert_path: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_tlsverify' do
          before { params.merge!(default_tlsverify: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_hostname' do
          before { params.merge!(default_hostname: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_cpuset_cpus' do
          before { params.merge!(default_cpuset_cpus: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_cpus' do
          before { params.merge!(default_cpus: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_dns' do
          before { params.merge!(default_dns: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_dns_search' do
          before { params.merge!(default_dns_search: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_privileged' do
          before { params.merge!(default_privileged: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_userns' do
          before { params.merge!(default_userns: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_cap_add' do
          before { params.merge!(default_cap_add: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_cap_drop' do
          before { params.merge!(default_cap_drop: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_security_opt' do
          before { params.merge!(default_security_opt: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_devices' do
          before { params.merge!(default_devices: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_disable_cache' do
          before { params.merge!(default_disable_cache: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_volumes' do
          before { params.merge!(default_volumes: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_volume_driver' do
          before { params.merge!(default_volume_driver: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_cache_dir' do
          before { params.merge!(default_cache_dir: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_extra_hosts' do
          before { params.merge!(default_extra_hosts: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_volumes_from' do
          before { params.merge!(default_volumes_from: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_network_mode' do
          before { params.merge!(default_network_mode: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_links' do
          before { params.merge!(default_links: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_services' do
          before { params.merge!(default_services: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_wait_for_services_timeout' do
          before { params.merge!(default_wait_for_services_timeout: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_allowed_images' do
          before { params.merge!(default_allowed_images: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_allowed_services' do
          before { params.merge!(default_allowed_services: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_pull_policy' do
          before { params.merge!(default_pull_policy: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_shm_size' do
          before { params.merge!(default_shm_size: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_ssh_user' do
          before { params.merge!(default_ssh_user: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_ssh_password' do
          before { params.merge!(default_ssh_password: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_ssh_host' do
          before { params.merge!(default_ssh_host: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_ssh_port' do
          before { params.merge!(default_ssh_port: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_ssh_identity_file' do
          before { params.merge!(default_ssh_identity_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
