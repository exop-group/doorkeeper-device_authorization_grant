# frozen_string_literal: true

require 'test_helper'

module Doorkeeper
  module DeviceAuthorizationGrant
    class ErrorsTest < ActiveSupport::TestCase
      test 'AuthorizationPending is a DoorkeeperError with type ' \
          'authorization_pending' do
        error = Errors::AuthorizationPending.new
        assert_kind_of ::Doorkeeper::Errors::DoorkeeperError, error
        assert_equal :authorization_pending, error.type
      end

      test 'SlowDown is a DoorkeeperError with type slow_down' do
        error = Errors::SlowDown.new
        assert_kind_of ::Doorkeeper::Errors::DoorkeeperError, error
        assert_equal :slow_down, error.type
      end

      test 'ExpiredToken is a DoorkeeperError with type expired_token' do
        error = Errors::ExpiredToken.new
        assert_kind_of ::Doorkeeper::Errors::DoorkeeperError, error
        assert_equal :expired_token, error.type
      end
    end
  end
end
