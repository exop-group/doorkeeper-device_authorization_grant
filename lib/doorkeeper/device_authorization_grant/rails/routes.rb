# frozen_string_literal: true

require_relative 'routes/mapper'

module Doorkeeper
  module DeviceAuthorizationGrant
    module Rails
      class Routes # rubocop:disable Style/Documentation
        module Helper # rubocop:disable Style/Documentation
          # @param options [Hash]
          def use_doorkeeper_device_authorization_grant(options = {}, &block)
            ::Doorkeeper::DeviceAuthorizationGrant::Rails::Routes
              .new(self, &block).generate_routes!(options)
          end
        end

        def self.install!
          ::ActionDispatch::Routing::Mapper.include(
            ::Doorkeeper::DeviceAuthorizationGrant::Rails::Routes::Helper
          )
        end

        attr_accessor :routes

        def initialize(routes, &block)
          @routes = routes
          @block = block
        end

        # @param options [Hash]
        def generate_routes!(options)
          @mapping = Mapper.new.map(&@block)

          routes.scope(options[:scope] || 'oauth', as: 'oauth') do
            map_route(:device_codes, :device_code_routes)
            map_route(:device_authorizations, :device_authorization_routes)
          end
        end

        private

        # @param name [Symbol]
        # @param method [Symbol]
        def map_route(name, method)
          return if @mapping.skipped?(name)

          mapping = @mapping[name]

          routes.scope(controller: mapping[:controller], as: mapping[:as]) do
            __send__(method)
          end
        end

        def device_authorization_routes
          routes.get(:index, path: 'device')
          routes.post(:authorize, path: 'device')
        end

        def device_code_routes
          routes.post(:create, path: 'authorize_device')
        end
      end
    end
  end
end
