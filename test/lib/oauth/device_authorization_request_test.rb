# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

module Doorkeeper
  module DeviceAuthorizationGrant
    module OAuth
      class DeviceAuthorizationRequestTest < ActiveSupport::TestCase
        setup do
          @application = Doorkeeper::Application.create!(
            name: 'Application',
            redirect_uri: 'https://example.com/application/redirect'
          )

          @server = Minitest::Mock.new
          @server.expect(:default_scopes, 'public')

          @request = DeviceAuthorizationRequest.new(
            @server,
            @application,
            'https://example.com'
          )

          config = Doorkeeper::DeviceAuthorizationGrant.configuration
          @original_config = {
            device_code_expires_in: config.device_code_expires_in,
            user_code_generator: config.user_code_generator
          }
        end

        teardown do
          original_config = @original_config
          Doorkeeper::DeviceAuthorizationGrant.configure do
            device_code_expires_in original_config[:device_code_expires_in]
            user_code_generator original_config[:user_code_generator]
          end
        end

        test 'it creates a new device grant' do
          assert_changes -> { DeviceGrant.count }, from: 0, to: 1 do
            @request.authorize
          end
        end

        test 'it returns a device authorization response' do
          assert_instance_of DeviceAuthorizationResponse, @request.authorize
        end

        test 'it requires the client' do
          @request.client = nil
          @request.validate
          assert_not @request.valid?
          assert_equal :invalid_client, @request.error
          assert_instance_of Doorkeeper::OAuth::ErrorResponse, @request.authorize
        end

        test 'only when valid, it removes expired device grants' do
          @expired_device_grant = DeviceGrant.create!(
            created_at: 611.seconds.ago,
            application: @application,
            expires_in: 60.seconds,
            user_code: 'foo'
          )

          @unexpired_device_grant = DeviceGrant.create!(
            application: @application,
            expires_in: 60.seconds,
            user_code: 'bar'
          )

          @request.client = nil
          @request.authorize

          assert_not_nil DeviceGrant.find_by(id: @expired_device_grant.id)
          assert_not_nil DeviceGrant.find_by(id: @unexpired_device_grant.id)

          @request.client = @application
          @request.authorize

          assert_nil DeviceGrant.find_by(id: @expired_device_grant.id)
          assert_not_nil DeviceGrant.find_by(id: @unexpired_device_grant.id)
        end

        test 'it assigns the correct application to the new device grant' do
          @request.authorize
          device_grant = DeviceGrant.first
          assert_equal @application, device_grant.application
          assert_equal @application.id, device_grant.application_id
        end

        test 'it assigns the default expires_in value to the new device grant if not configured' do
          @request.authorize
          device_grant = DeviceGrant.first
          assert_equal 300, device_grant.expires_in
        end

        test 'the new device grant expires_in can be customized' do
          Doorkeeper::DeviceAuthorizationGrant.configure do
            device_code_expires_in 10.minutes
          end

          @request.authorize
          device_grant = DeviceGrant.first
          assert_equal 600, device_grant.expires_in
        end

        test 'it assigns the correct scopes to the new device grant' do
          @request.authorize
          device_grant = DeviceGrant.first
          assert_equal 'public', device_grant.scopes
          @server.verify
        end

        test 'it assigns a user code to the new device grant with the default generator if not configured' do
          @request.authorize
          device_grant = DeviceGrant.first
          assert_instance_of String, device_grant.user_code
          assert_match(/^[A-Z\d]{8}$/, device_grant.user_code)
        end

        test 'the new device grant user code generator can be customized' do
          Doorkeeper::DeviceAuthorizationGrant.configure do
            user_code_generator FakeUserCodeGenerator.name
          end

          @request.authorize
          device_grant = DeviceGrant.first
          assert_equal 'foo-bar', device_grant.user_code
        end

        module FakeUserCodeGenerator
          def self.generate
            'foo-bar'
          end
        end
      end
    end
  end
end
