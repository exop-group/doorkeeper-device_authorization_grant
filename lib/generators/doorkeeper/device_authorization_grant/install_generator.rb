# frozen_string_literal: true

module Doorkeeper
  module DeviceAuthorizationGrant
    # Rails generator to install DeviceAuthorizationGrant initializer and routes.
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('./templates', __dir__)
      desc 'Installs Doorkeeper DeviceAuthorizationGrant.'

      def install
        template('initializer.rb', 'config/initializers/doorkeeper_device_authorization_grant.rb')
        route('use_doorkeeper_device_authorization_grant')
      end
    end
  end
end
