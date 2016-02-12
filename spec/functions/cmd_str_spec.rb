require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.0.0') >= 0
  describe 'gitlab::cirunner::cmd_str' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params().and_raise_error(ArgumentError) }
    it { is_expected.to run.with_params('', '').and_raise_error(ArgumentError) }
    it { is_expected.to run.with_params('', [], '').and_raise_error(ArgumentError) }
    it 'test True first with undef' do
      is_expected.to run.with_params('foobar', [true, nil, nil]).and_return(
        '--foobar'
      )
    end
    it 'test True second with undef' do
      is_expected.to run.with_params('foobar', [nil, true, nil]).and_return(
        '--foobar'
      )
    end
    it 'test True last with undef' do
      is_expected.to run.with_params('foobar', [nil, nil, true]).and_return(
        '--foobar'
      )
    end
    it 'test True first with False' do
      is_expected.to run.with_params('foobar', [true, false, false]).and_return(
        '--foobar'
      )
    end
    it 'test True second with False' do
      is_expected.to run.with_params('foobar', [false, true, false]).and_return(
        ''
      )
    end
    it 'test True last with False' do
      is_expected.to run.with_params('foobar', [false, false, true]).and_return(
        ''
      )
    end
    it 'test String first with undef' do
      is_expected.to run.with_params('foobar', ['first', nil, nil]).and_return(
        '--foobar first'
      )
    end
    it 'test String second with undef' do
      is_expected.to run.with_params('foobar', [nil, 'second', nil]).and_return(
        '--foobar second'
      )
    end
    it 'test String last with undef' do
      is_expected.to run.with_params('foobar', [nil, nil, 'third']).and_return(
        '--foobar third'
      )
    end
    it 'test String first with Strings' do
      is_expected.to run.with_params('foobar', ['first', 'second', 'third']).and_return(
        '--foobar first'
      )
    end
    it 'test String second with Strings' do
      is_expected.to run.with_params('foobar', [nil, 'second', nil]).and_return(
        '--foobar second'
      )
    end
    it 'test Array first with undef' do
      is_expected.to run.with_params(
        'foobar', [['first1', 'first2'], nil, nil]
      ).and_return(
        '--foobar first1,first2'
      )
    end
    it 'test Array second with undef' do
      is_expected.to run.with_params(
        'foobar', [nil, ['second1', 'second2'], nil]
      ).and_return(
        '--foobar second1,second2'
      )
    end
    it 'test Array last with undef' do
      is_expected.to run.with_params(
        'foobar', [nil, nil, ['third1', 'third2']]
      ).and_return(
        '--foobar third1,third2'
      )
    end
    it 'test Array first with undef' do
      is_expected.to run.with_params(
        'foobar', [['first1', 'first2'], ['second1', 'second2'], ['third1', 'third2']]
      ).and_return(
        '--foobar first1,first2'
      )
    end
    it 'test Array second with undef' do
      is_expected.to run.with_params(
        'foobar', [nil, ['second1', 'second2'], ['third1', 'third2']]
      ).and_return(
        '--foobar second1,second2'
      )
    end
  end
end
