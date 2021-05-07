require 'spec_helper'

describe 'gitlab::system_hook' do
  let(:title) { 'test-system-hook' }

  let(:pre_condition) do
    <<-MANIFEST
    class { 'gitlab':
      repository_configuration => {},
    }
    MANIFEST
  end

  context "with type => #{type} and source" do
    let(:source) { 'puppet:///modules/my_module/file-hook' }
    let(:params) do
      {
        custom_hooks_dir: '/custom/hooks/dir',
        source: source
      }
    end

    it { is_expected.to compile.with_all_deps }

    it do
      is_expected.to contain_file("/custom/hooks/dir").
        with_ensure('directory')
    end

    it do
      is_expected.to contain_file("/custom/hooks/dir/#{title}").
        with_ensure('file').
        with_source(source)
    end
  end

  context "with type => #{type} and content" do
    let(:content) { "#!/usr/bin/env bash\ntest 0" }
    let(:params) do
      {
        custom_hooks_dir: '/custom/hooks/dir',
        content: content
      }
    end

    it { is_expected.to compile }

    it do
      is_expected.to contain_file("/custom/hooks/dir").
        with_ensure('directory')
    end

    it do
      is_expected.to contain_file("/custom/hooks/dir/#{title}").
        with_ensure('file').
        with_content(content)
    end
  end
end
