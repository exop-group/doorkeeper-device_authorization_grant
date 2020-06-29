# frozen_string_literal: true

require 'active_support/lazy_load_hooks'

module Doorkeeper # rubocop:disable Style/Documentation
  module DeviceAuthorizationGrant
    module Orm
      # @deprecated Doorkeeper `active_record_options` is deprecated: customize Doorkeeper models instead.
      module ActiveRecord
        def self.initialize_models!
          super

          ActiveSupport.on_load(:active_record) do
            require_relative 'active_record/device_grant'

            options = Doorkeeper.configuration.active_record_options
            establish_connection_option = options[:establish_connection]

            DeviceGrant.establish_connection(establish_connection_option) if establish_connection_option
          end
        end
      end
    end
  end

  Orm::ActiveRecord.singleton_class.prepend(DeviceAuthorizationGrant::Orm::ActiveRecord)
end
