# frozen_string_literal: true

module Doorkeeper
  module Request
    # Doorkeeper strategy for OAuth 2.0 Device Access Token Requests.
    #
    # @see https://tools.ietf.org/html/rfc8628#section-3.4 RFC 8628, sect. 3.4
    class DeviceCode < ::Doorkeeper::Request::Strategy
      delegate :parameters, :client, to: :server

      # @return [::Doorkeeper::DeviceAuthorizationGrant::OAuth::DeviceCodeRequest]
      def request
        @request ||=
          ::Doorkeeper::DeviceAuthorizationGrant::OAuth::DeviceCodeRequest
          .new(Doorkeeper.configuration, client, device_grant)
      end

      private

      delegate :device_grant_model, to: :configuration

      # @return [::Doorkeeper::DeviceAuthorizationGrant::DeviceGrant, nil]
      def device_grant
        @device_grant ||= device_grant_model.by_device_code(parameters[:device_code])
      end

      # @return [::Doorkeeper::DeviceAuthorizationGrant::Config]
      def configuration
        @configuration ||= DeviceAuthorizationGrant.configuration
      end
    end
  end
end
