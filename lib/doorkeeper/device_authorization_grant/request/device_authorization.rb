# frozen_string_literal: true

module Doorkeeper
  module DeviceAuthorizationGrant
    module Request
      # Doorkeeper strategy for OAuth 2.0 Device Authorization Requests.
      #
      # @see https://tools.ietf.org/html/rfc8628#section-3.1 RFC 8628, sect. 3.1
      class DeviceAuthorization < ::Doorkeeper::Request::Strategy
        delegate :client, :parameters, to: :server

        # @return [OAuth::DeviceAuthorizationRequest]
        def request
          @request ||= OAuth::DeviceAuthorizationRequest.new(
            Doorkeeper.configuration,
            client,
            host_name,
            parameters
          )
        end

        private

        # @return [String]
        def host_name
          req = server.context.request
          "#{req.scheme}://#{req.host}#{port}"
        end

        # @return [String, nil]
        def port
          return nil if [80, 443].include?(server.context.request.port)

          ":#{server.context.request.port}"
        end
      end
    end
  end
end
