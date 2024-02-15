# frozen_string_literal: true

require 'spec_helper'

describe 'gitlab::custom_hook' do
  let(:title) { 'test-hook' }

  let(:pre_condition) do
    <<-MANIFEST
    class { 'gitlab':
      repository_configuration => {},
    }
    MANIFEST
  end

  ['post-receive', 'pre-receive', 'update'].each do |type|
    context "with type => #{type} and source" do
      let(:source) { 'puppet:///modules/my_module/post-receive' }
      let(:params) do
        {
          type: type,
          repos_path: '/custom/hooks/dir',
          source: source,
          namespace: 'foo',
          project: 'bar'
        }
      end

      it { is_expected.to compile }

      it do
        is_expected.to contain_file('/custom/hooks/dir/foo/bar.git/custom_hooks').
          with_ensure('directory')
      end

      it do
        is_expected.to contain_file("/custom/hooks/dir/foo/bar.git/custom_hooks/#{type}").
          with_ensure('file').
          with_source(source)
      end
    end

    context "with type => #{type} and content" do
      let(:content) { "#!/usr/bin/env bash\ntest 0" }
      let(:params) do
        {
          type: type,
          repos_path: '/custom/hooks/dir',
          content: content,
          namespace: 'foo',
          project: 'bar'
        }
      end

      it { is_expected.to compile }

      it do
        is_expected.to contain_file('/custom/hooks/dir/foo/bar.git/custom_hooks').
          with_ensure('directory')
      end

      it do
        is_expected.to contain_file("/custom/hooks/dir/foo/bar.git/custom_hooks/#{type}").
          with_ensure('file').
          with_content(content)
      end
    end

    context "with type => #{type} and project hash" do
      let(:content) { "#!/usr/bin/env bash\ntest 0" }
      let(:params) do
        {
          type: type,
          repos_path: '/custom/hooks/dir',
          content: content,
          hashed_storage: true,
          project: '6e4001871c0cf27c7634ef1dc478408f642410fd3a444e2a88e301f5c4a35a4d'
        }
      end

      it { is_expected.to compile }

      it do
        is_expected.to contain_file('/custom/hooks/dir/@hashed/6e/40/6e4001871c0cf27c7634ef1dc478408f642410fd3a444e2a88e301f5c4a35a4d.git/custom_hooks').
          with_ensure('directory')
      end

      it do
        is_expected.to contain_file("/custom/hooks/dir/@hashed/6e/40/6e4001871c0cf27c7634ef1dc478408f642410fd3a444e2a88e301f5c4a35a4d.git/custom_hooks/#{type}").
          with_ensure('file').
          with_content(content)
      end
    end

    context "with type => #{type} and project id" do
      let(:content) { "#!/usr/bin/env bash\ntest 0" }
      let(:params) do
        {
          type: type,
          repos_path: '/custom/hooks/dir',
          content: content,
          hashed_storage: true,
          project: 93
        }
      end

      it { is_expected.to compile }

      it do
        is_expected.to contain_file('/custom/hooks/dir/@hashed/6e/40/6e4001871c0cf27c7634ef1dc478408f642410fd3a444e2a88e301f5c4a35a4d.git/custom_hooks').
          with_ensure('directory')
      end

      it do
        is_expected.to contain_file("/custom/hooks/dir/@hashed/6e/40/6e4001871c0cf27c7634ef1dc478408f642410fd3a444e2a88e301f5c4a35a4d.git/custom_hooks/#{type}").
          with_ensure('file').
          with_content(content)
      end
    end
  end
end
