# frozen_string_literal: true

module Doorkeeper
  module DeviceAuthorizationGrant
    module Rails
      class Routes
        class Mapping # rubocop:disable Style/Documentation
          # @return [Hash{Symbol => String}]
          attr_accessor :controllers

          # @return [Hash{Symbol => Symbol}]
          attr_accessor :as

          # @return [Array<Symbol>]
          attr_accessor :skips

          def initialize
            @controllers = {
              device_authorizations: 'doorkeeper/device_authorization_grant/device_authorizations',
              device_codes: 'doorkeeper/device_authorization_grant/device_codes'
            }

            @as = {
              device_authorizations: :device_authorizations,
              device_codes: :device_codes
            }

            @skips = []
          end

          # @param routes [Symbol]
          # @return [Hash]
          def [](routes)
            {
              controller: @controllers[routes],
              as: @as[routes]
            }
          end

          # @param controller [Symbol]
          # @return [Boolean]
          def skipped?(controller)
            @skips.include?(controller)
          end
        end
      end
    end
  end
end
