# frozen_string_literal: true

require 'test_helper'

module Doorkeeper
  module DeviceAuthorizationGrant
    module OAuth
      module Helpers
        class UserCodeTest < ActiveSupport::TestCase
          test 'generates a string with 8 mixed digits and upcase chars' do
            assert_match(/^[A-Z\d]{8}$/, UserCode.generate)
          end

          test 'generates a new random string at each call' do
            first_code = UserCode.generate
            10.times { assert_not_equal(first_code, UserCode.generate) }
          end
        end
      end
    end
  end
end
