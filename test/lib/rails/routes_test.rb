# frozen_string_literal: true

require 'test_helper'

module Doorkeeper
  module DeviceAuthorizationGrant
    module Rails
      class RoutesTest < ActionDispatch::IntegrationTest
        test 'it maps POST /oauth/authorize_device to device_codes#create' do
          assert_routing(
            {
              method: 'post',
              path: '/oauth/authorize_device'
            },
            action: 'create',
            controller: 'doorkeeper/device_authorization_grant/device_codes'
          )
        end

        test 'it maps GET /oauth/device to device_authorizations#index' do
          assert_routing(
            {
              method: 'get',
              path: '/oauth/device'
            },
            action: 'index',
            controller: 'doorkeeper/device_authorization_grant/device_authorizations'
          )
        end

        test 'it maps POST /oauth/device to device_authorizations#authorize' do
          assert_routing(
            {
              method: 'post',
              path: '/oauth/device'
            },
            action: 'authorize',
            controller: 'doorkeeper/device_authorization_grant/device_authorizations'
          )
        end
      end
    end
  end
end
