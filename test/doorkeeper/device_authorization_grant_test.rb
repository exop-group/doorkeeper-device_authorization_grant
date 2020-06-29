# frozen_string_literal: true

require 'test_helper'

module Doorkeeper
  module DeviceAuthorizationGrant
    class Test < ActiveSupport::TestCase
      test 'truth' do
        assert_kind_of Module, Doorkeeper::DeviceAuthorizationGrant
      end
    end
  end
end
