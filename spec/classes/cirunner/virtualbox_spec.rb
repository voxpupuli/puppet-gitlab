require 'spec_helper'

describe 'gitlab::cirunner::virtualbox' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'gitlab::cirunner::virtualbox.example.com' }

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
      # runners: {},
      # default_coordinator: :undef,
      # default_run_untagged: :undef,
      # default_locked: :undef,
      # default_tags: :undef,
      # default_base_name: :undef,
      # default_template_name: :undef,
      # default_disable_snapshots: true,

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }

  test_on = {
    :hardwaremodels => ['x86_64'],
    :supported_os   => [
      {
        'operatingsystem'        => 'Debian',
        'operatingsystemrelease' => ['7'],
      },
    ],
  }
  on_supported_os(test_on).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
      end
      describe 'check bad type' do
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
        context 'default_base_name' do
          before { params.merge!(default_base_name: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_template_name' do
          before { params.merge!(default_template_name: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_disable_snapshots' do
          before { params.merge!(default_disable_snapshots: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
