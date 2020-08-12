require 'spec_helper'

describe 'gitlab::global_hook' do
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
          custom_hooks_dir: '/custom/hooks/dir',
          source: source
        }
      end

      it { is_expected.to compile }

      it do
        is_expected.to contain_file("/custom/hooks/dir/#{type}.d").
          with_ensure('directory')
      end

      it do
        is_expected.to contain_file("/custom/hooks/dir/#{type}.d/#{title}").
          with_ensure('file').
          with_source(source)
      end
    end

    context "with type => #{type} and content" do
      let(:content) { "#!/usr/bin/env bash\ntest 0" }
      let(:params) do
        {
          type: type,
          custom_hooks_dir: '/custom/hooks/dir',
          content: content
        }
      end

      it { is_expected.to compile }

      it do
        is_expected.to contain_file("/custom/hooks/dir/#{type}.d").
          with_ensure('directory')
      end

      it do
        is_expected.to contain_file("/custom/hooks/dir/#{type}.d/#{title}").
          with_ensure('file').
          with_content(content)
      end
    end
  end
end
