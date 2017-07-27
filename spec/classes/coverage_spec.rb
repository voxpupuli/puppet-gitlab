# frozen_string_literal: true

require 'rspec-puppet'

at_exit { RSpec::Puppet::Coverage.report! }
