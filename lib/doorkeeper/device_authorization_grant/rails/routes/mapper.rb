# frozen_string_literal: true

require_relative 'mapping'

module Doorkeeper
  module DeviceAuthorizationGrant
    module Rails
      class Routes
        class Mapper # rubocop:disable Style/Documentation
          # @param mapping [Mapping]
          def initialize(mapping = Mapping.new)
            @mapping = mapping
          end

          # @return [Mapping]
          def map(&block)
            instance_eval(&block) if block
            @mapping
          end

          # @param controller_names [Hash{Symbol => String}]
          # @return [Hash{Symbol => String}]
          def controller(controller_names = {})
            @mapping.controllers.merge!(controller_names)
          end

          # @param controller_names [Array<Symbol>]
          def skip_controllers(*controller_names)
            @mapping.skips = controller_names
          end

          # @param alias_names [Hash{Symbol => Symbol}]
          def as(alias_names = {})
            @mapping.as.merge!(alias_names)
          end
        end
      end
    end
  end
end
