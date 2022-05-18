# frozen_string_literal: true

module Doorkeeper
  module DeviceAuthorizationGrant
    module OAuth
      # Doorkeeper request object for handling OAuth 2.0 Device Authorization Requests.
      #
      # @see https://tools.ietf.org/html/rfc8628#section-3.1 RFC 8628, sect. 3.1
      class DeviceAuthorizationRequest < Doorkeeper::OAuth::BaseRequest
        attr_accessor :server, :client

        # @return [String]
        attr_accessor :host_name

        validate :client, error: :invalid_client

        # @param server
        # @param client
        # @param host_name [String]
        # @param parameters [Hash]
        def initialize(server, client, host_name, parameters = {}) # rubocop:disable Style/OptionHash
          super()
          @server = server
          @client = client
          @host_name = host_name
          @original_scopes = parameters[:scope]
        end

        # @return [DeviceAuthorizationResponse, Doorkeeper::OAuth::ErrorResponse]
        def authorize
          validate

          @response =
            if valid?
              destroy_expired_device_grants!
              create_successful_response
            else
              Doorkeeper::OAuth::ErrorResponse.from_request(self)
            end
        end

        private

        delegate :device_grant_model, to: :configuration

        def destroy_expired_device_grants!
          device_grant_model.expired.destroy_all
        end

        # @return [DeviceAuthorizationResponse]
        def create_successful_response
          before_successful_response
          response = DeviceAuthorizationResponse.new(device_grant, host_name)
          after_successful_response
          response
        end

        # @return [Boolean]
        def validate_client
          client.present?
        end

        # @return [Doorkeeper::DeviceAuthorizationGrant::DeviceGrant]
        def device_grant
          @device_grant ||= device_grant_model.create!(device_grant_attributes)
        end

        # @return [Hash]
        def device_grant_attributes
          {
            application_id: client.id,
            expires_in: configuration.device_code_expires_in,
            scopes: scopes.to_s,
            user_code: generate_user_code
          }
        end

        # @return [String]
        def generate_user_code
          configuration.user_code_generator_class.generate
        end

        # @return [::Doorkeeper::DeviceAuthorizationGrant::Config]
        def configuration
          @configuration ||= DeviceAuthorizationGrant.configuration
        end
      end
    end
  end
end
