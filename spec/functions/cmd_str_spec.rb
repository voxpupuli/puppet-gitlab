require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.0.0') >= 0
  describe 'gitlab::cirunner::cmd_str' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params.and_raise_error(ArgumentError) }
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
    it 'test string as first param all others blank' do
      is_expected.to run.with_params('foobar', ['first', nil, nil]).and_return(
        '--foobar first'
      )
    end
    it 'String second with undef' do
      is_expected.to run.with_params('foobar', [nil, 'second', nil]).and_return(
        '--foobar second'
      )
    end
    it 'test String last with undef' do
      is_expected.to run.with_params('foobar', [nil, nil, 'third']).and_return(
        '--foobar third'
      )
    end
    it 'test with all strings filled' do
      is_expected.to run.with_params('foobar', %w[first second third]).and_return(
        '--foobar first'
      )
    end
    it 'test Array first with undef' do
      is_expected.to run.with_params(
        'foobar', [%w[first1 first2], nil, nil]
      ).and_return(
        '--foobar first1,first2'
      )
    end
    it 'test Array second with undef' do
      is_expected.to run.with_params(
        'foobar', [nil, %w[second1 second2], nil]
      ).and_return(
        '--foobar second1,second2'
      )
    end
    it 'test Array last with undef' do
      is_expected.to run.with_params(
        'foobar', [nil, nil, %w[third1 third2]]
      ).and_return(
        '--foobar third1,third2'
      )
    end
    it 'test Array first with undef' do
      is_expected.to run.with_params(
        'foobar', [%w[first1 first2], %w[second1 second2], %w[third1 third2]]
      ).and_return(
        '--foobar first1,first2'
      )
    end
    it 'test Array second with undef' do
      is_expected.to run.with_params(
        'foobar', [nil, %w[second1 second2], %w[third1 third2]]
      ).and_return(
        '--foobar second1,second2'
      )
    end
  end
end
