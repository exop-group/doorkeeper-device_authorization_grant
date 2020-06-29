# frozen_string_literal: true

require 'test_helper'

module Doorkeeper
  module DeviceAuthorizationGrant
    class VersionTest < ActiveSupport::TestCase
      test 'VERSION contains the gem version string' do
        assert_match(
          /^\d+\.\d+\.\d+$/,
          ::Doorkeeper::DeviceAuthorizationGrant::VERSION
        )
      end
    end
  end
end
