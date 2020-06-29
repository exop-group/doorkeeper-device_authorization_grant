# frozen_string_literal: true

module Doorkeeper
  module DeviceAuthorizationGrant
    # Doorkeeper DeviceAuthorizationGrant Rails Engine
    class Engine < ::Rails::Engine
      initializer 'doorkeeper.device_authorization_grant.routes' do
        ::Doorkeeper::DeviceAuthorizationGrant::Rails::Routes.install!
      end
    end
  end
end
