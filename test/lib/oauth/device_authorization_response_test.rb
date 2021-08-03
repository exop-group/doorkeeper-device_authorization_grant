# frozen_string_literal: true

require 'test_helper'

module Doorkeeper
  module DeviceAuthorizationGrant
    module OAuth
      class DeviceAuthorizationResponseTest < ActiveSupport::TestCase
        setup do
          application = Doorkeeper::Application.create!(
            name: 'Application',
            redirect_uri: 'https://example.com/application/redirect'
          )

          @device_grant = DeviceGrant.create!(
            application: application,
            expires_in: 5.minutes,
            user_code: 'foo'
          )
          @host_name = 'https://example.com'
          @response = DeviceAuthorizationResponse.new(@device_grant, @host_name)

          config = Doorkeeper::DeviceAuthorizationGrant.configuration
          @original_config = {
            verification_uri: config.verification_uri,
            verification_uri_complete: config.verification_uri_complete,
            device_code_polling_interval: config.device_code_polling_interval
          }
        end

        teardown do
          orig_cnf = @original_config
          Doorkeeper::DeviceAuthorizationGrant.configure do
            verification_uri orig_cnf[:verification_uri]
            verification_uri_complete orig_cnf[:verification_uri_complete]
            device_code_polling_interval orig_cnf[:device_code_polling_interval]
          end
        end

        test '#headers include no-store and no-cache' do
          headers = @response.headers
          assert_equal 'no-store', headers['Cache-Control']
          assert_equal 'no-cache', headers['Pragma']
        end

        test '#headers content type is JSON' do
          assert_equal \
            'application/json; charset=utf-8', @response.headers['Content-Type']
        end

        test '#status is ok' do
          assert_equal :ok, @response.status
        end

        test '#body includes the device code' do
          assert_equal @device_grant.plaintext_device_code, @response.body['device_code']
        end

        test '#body includes the user code' do
          assert_equal @device_grant.user_code, @response.body['user_code']
        end

        test '#body includes the default verification URI ' \
          'if it was not customized' do
          assert_equal \
            'https://example.com/oauth/device',
            @response.body['verification_uri']
        end

        test '#body includes the default complete verification URI ' \
          'if it was not customized' do
          assert_equal\
            "https://example.com/oauth/device?user_code=#{@device_grant.user_code}",
            @response.body['verification_uri_complete']
        end

        test '#body verification URIs can be customized' do
          Doorkeeper::DeviceAuthorizationGrant.configure do
            verification_uri ->(host_name) { "#{host_name}/foo/bar" }
          end

          assert_equal \
            'https://example.com/foo/bar',
            @response.body['verification_uri']
        end

        test '#body complete verification URI can be customized based on ' \
          'the verification URI' do
          Doorkeeper::DeviceAuthorizationGrant.configure do
            verification_uri_complete(
              lambda do |verif_uri, _host_name, grant|
                "#{verif_uri}/#{grant.user_code}"
              end
            )
          end

          assert_equal \
            "https://example.com/oauth/device/#{@device_grant.user_code}",
            @response.body['verification_uri_complete']
        end

        test '#body complete verification URI can be customized based on ' \
          'the host name' do
          Doorkeeper::DeviceAuthorizationGrant.configure do
            verification_uri_complete(
              lambda do |_verif_uri, host_name, grant|
                "#{host_name}/baz/#{grant.user_code}"
              end
            )
          end

          assert_equal \
            "https://example.com/baz/#{@device_grant.user_code}",
            @response.body['verification_uri_complete']
        end

        test '#body complete verification URI can be omitted' do
          Doorkeeper::DeviceAuthorizationGrant.configure do
            verification_uri_complete ->(*) {}
          end

          refute_includes @response.body, 'verification_uri_complete'
        end

        test '#body includes expires_in' do
          assert_equal \
            @device_grant.expires_in.seconds,
            @response.body['expires_in']
        end

        test '#body includes the default interval' do
          assert_equal 5, @response.body['interval']
        end

        test '#body interval can be customized' do
          Doorkeeper::DeviceAuthorizationGrant.configure do
            device_code_polling_interval 1.minute
          end

          assert_equal 60, @response.body['interval']
        end

        test '#body interval can be omitted' do
          Doorkeeper::DeviceAuthorizationGrant.configure do
            device_code_polling_interval nil
          end

          refute_includes @response.body, 'interval'
        end
      end
    end
  end
end
