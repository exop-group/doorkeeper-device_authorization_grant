# frozen_string_literal: true

module Doorkeeper
  module DeviceAuthorizationGrant
    module OAuth
      # Doorkeeper response object for handling OAuth 2.0 Device Authorization Responses.
      #
      # @see https://tools.ietf.org/html/rfc8628#section-3.2 RFC 8628, sect. 3.2
      class DeviceAuthorizationResponse < Doorkeeper::OAuth::BaseResponse
        # @return [DeviceGrant]
        attr_accessor :device_grant

        # @return [String]
        attr_accessor :host_name

        # @param device_grant [DeviceGrant]
        # @param host_name [String]
        def initialize(device_grant, host_name)
          super()
          @device_grant = device_grant
          @host_name = host_name
        end

        # @return [Symbol]
        def status
          :ok
        end

        # @return [Hash]
        def body
          {
            'device_code' => device_grant.plaintext_device_code,
            'user_code' => device_grant.user_code,
            'verification_uri' => verification_uri,
            'verification_uri_complete' => verification_uri_complete,
            'expires_in' => device_grant.expires_in,
            'interval' => interval
          }.reject { |_, value| value.blank? } # rubocop:disable Rails/CompactBlank does not exist in Rails < 6.1
        end

        # @return [Hash]
        def headers
          {
            'Cache-Control' => 'no-store',
            'Pragma' => 'no-cache',
            'Content-Type' => 'application/json; charset=utf-8'
          }
        end

        private

        # @return [String]
        def verification_uri
          configuration.verification_uri.call(host_name)
        end

        # @return [String, nil]
        def verification_uri_complete
          configuration.verification_uri_complete.call(verification_uri, host_name, device_grant)
        end

        # @return [Integer, nil]
        def interval
          configuration.device_code_polling_interval&.seconds&.to_i
        end

        # @return [::Doorkeeper::DeviceAuthorizationGrant::Config]
        def configuration
          @configuration ||= Doorkeeper::DeviceAuthorizationGrant.configuration
        end
      end
    end
  end
end
