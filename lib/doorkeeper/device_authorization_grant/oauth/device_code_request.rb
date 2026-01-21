# frozen_string_literal: true

module Doorkeeper
  module DeviceAuthorizationGrant
    module OAuth
      # Doorkeeper request object for handling OAuth 2.0 Device Access Token Requests.
      #
      # @see https://tools.ietf.org/html/rfc8628#section-3.4 RFC 8628, sect. 3.4
      class DeviceCodeRequest < ::Doorkeeper::OAuth::BaseRequest
        attr_accessor :server, :client, :access_token

        # @return [DeviceGrant]
        attr_accessor :device_grant

        validate :client, error: :invalid_client
        validate :device_grant, error: :invalid_grant

        # @param server
        # @param client
        # @param device_grant [DeviceGrant]
        def initialize(server, client, device_grant)
          super()

          @server = server
          @client = client
          @device_grant = device_grant

          @grant_type = Doorkeeper::DeviceAuthorizationGrant::OAuth::DEVICE_CODE
        end

        def before_successful_response
          check_grant_errors!
          check_user_interaction!

          device_grant.transaction do
            device_grant.lock!
            device_grant.destroy!
            generate_access_token
          end

          super
        end

        private

        def generate_access_token
          # Doorkeeper 5.6.5 introduced an additional argument, see https://github.com/doorkeeper-gem/doorkeeper/pull/1602
          if Doorkeeper.gem_version >= Gem::Version.new('5.6.5')
            generate_access_token_with_empty_custom_attributes
          else
            generate_access_token_without_custom_attributes
          end
        end

        def generate_access_token_with_empty_custom_attributes
          find_or_create_access_token(
            device_grant.application,
            resource_owner,
            device_grant.scopes,
            {},
            server
          )
        end

        def generate_access_token_without_custom_attributes
          find_or_create_access_token(
            device_grant.application,
            resource_owner,
            device_grant.scopes,
            server
          )
        end

        def resource_owner
          if Doorkeeper.config.polymorphic_resource_owner?
            device_grant.resource_owner
          else
            device_grant.resource_owner_id
          end
        end

        def check_grant_errors!
          return unless device_grant.expired?

          device_grant.destroy!
          raise Errors::ExpiredToken
        end

        def check_user_interaction!
          raise Errors::SlowDown if polling_too_fast?

          device_grant.update!(last_polling_at: Time.now.utc)

          raise Errors::AuthorizationPending if authorization_pending?
        end

        # @return [Boolean]
        def polling_too_fast?
          !device_grant.last_polling_at.nil? &&
            device_grant.last_polling_at > device_code_polling_interval.ago
        end

        # @return [Boolean]
        def authorization_pending?
          !device_grant.user_code.nil?
        end

        # @return [Boolean]
        def validate_client
          client.present?
        end

        # @return [Boolean]
        def validate_device_grant
          device_grant.present? && device_grant.application_id == client.id
        end

        # @return [ActiveSupport::Duration]
        def device_code_polling_interval
          configuration.device_code_polling_interval.seconds
        end

        # @return [::Doorkeeper::DeviceAuthorizationGrant::Config]
        def configuration
          Doorkeeper::DeviceAuthorizationGrant.configuration
        end
      end
    end
  end
end
