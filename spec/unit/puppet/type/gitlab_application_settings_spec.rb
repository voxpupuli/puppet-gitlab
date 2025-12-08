# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/gitlab_application_settings'

describe 'gitlab_application_settings type' do
  it 'loads' do
    expect(Puppet::Type.type(:gitlab_application_settings)).not_to be_nil
  end
end
