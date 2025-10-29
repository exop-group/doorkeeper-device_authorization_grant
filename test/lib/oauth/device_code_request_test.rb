# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

module Doorkeeper
  module DeviceAuthorizationGrant
    module OAuth
      class DeviceCodeRequestTest < ActiveSupport::TestCase
        setup do
          @application = Doorkeeper::Application.create!(
            name: 'Application',
            redirect_uri: 'https://example.com/application/redirect'
          )

          @server = Minitest::Mock.new
          @server.expect(:access_token_expires_in, 2.days)
          @server.expect(
            :option_defined?,
            false,
            [:custom_access_token_expires_in]
          )
          def @server.refresh_token_enabled?
            false
          end

          @expired_device_grant = DeviceGrant.create!(
            created_at: 61.seconds.ago,
            application: @application,
            expires_in: 60.seconds,
            user_code: 'ab-cd'
          )

          @unverified_device_grant = DeviceGrant.create!(
            application: @application,
            expires_in: 60.seconds,
            user_code: 'ef-gh'
          )

          @verified_device_grant = DeviceGrant.create!(
            resource_owner_id: 123,
            application: @application,
            expires_in: 60.seconds,
            scopes: 'grant-scopes'
          )
        end

        test '#authorize raises ExpiredToken error if the device grant is expired and deletes the device grant' do
          request = DeviceCodeRequest.new(@server, @application, @expired_device_grant)

          assert_raises Errors::ExpiredToken do
            request.authorize
          end

          assert_nil DeviceGrant.find_by(id: @expired_device_grant.id)
        end

        test '#authorize raises AuthorizationPending error if the device grant has not been verified' do
          request = DeviceCodeRequest.new(@server, @application, @unverified_device_grant)

          assert_raises Errors::AuthorizationPending do
            request.authorize
          end
        end

        test '#authorize raises SlowDown error when polling too frequently' do
          @unverified_device_grant.update!(last_polling_at: 1.second.ago)
          request = DeviceCodeRequest.new(@server, @application, @unverified_device_grant)
          assert_raises Errors::SlowDown do
            request.authorize
          end
        end

        test '#authorize issues a new token if the device grant has been verified' do
          request = DeviceCodeRequest.new(@server, @application, @verified_device_grant)
          assert_equal 0, @application.reload.access_tokens.count

          request.authorize
          assert_equal 1, @application.reload.access_tokens.count
        end

        test '#authorize with a verified device grant issues a new token with same device grant scopes' do
          request = DeviceCodeRequest.new(@server, @application, @verified_device_grant)
          request.authorize
          assert_equal @verified_device_grant.scopes, Doorkeeper::AccessToken.last.scopes.to_s
        end

        test '#authorize with a verified device grant deletes the device grant' do
          request = DeviceCodeRequest.new(@server, @application, @verified_device_grant)
          request.authorize
          assert_nil DeviceGrant.find_by(id: @verified_device_grant.id)
        end

        test '#authorize updates the polling interval of an unverified device grant' do
          assert_nil @unverified_device_grant.last_polling_at
          request = DeviceCodeRequest.new(@server, @application, @unverified_device_grant)
          suppress(Errors::AuthorizationPending) { request.authorize }
          assert_not_nil @unverified_device_grant.reload.last_polling_at
        end

        test 'it requires the client' do
          request = DeviceCodeRequest.new(@server, nil, @verified_device_grant)
          request.validate
          assert_equal :invalid_client, request.error
          assert_instance_of Doorkeeper::OAuth::ErrorResponse, request.authorize
        end

        test 'it requires the device grant' do
          request = DeviceCodeRequest.new(@server, @application, nil)
          request.validate
          assert_equal :invalid_grant, request.error
          assert_instance_of Doorkeeper::OAuth::ErrorResponse, request.authorize
        end

        test 'it requires the device grant application to be the same as the client' do
          another_app = Doorkeeper::Application.create!(
            name: 'Another App',
            redirect_uri: 'https://example.com/'
          )
          @verified_device_grant.application = another_app
          request = DeviceCodeRequest.new(@server, @application, @verified_device_grant)
          request.validate
          assert_equal :invalid_grant, request.error
          assert_instance_of Doorkeeper::OAuth::ErrorResponse, request.authorize
        end
      end
    end
  end
end
