# frozen_string_literal: true

require 'doorkeeper'
require 'active_model'
require 'doorkeeper/device_authorization_grant/config'
require 'doorkeeper/device_authorization_grant/engine'

module Doorkeeper
  # OAuth 2.0 Device Authorization Grant extension for Doorkeeper.
  module DeviceAuthorizationGrant
    autoload :DeviceGrant, 'doorkeeper/device_authorization_grant/orm/active_record/device_grant'
    autoload :Errors, 'doorkeeper/device_authorization_grant/errors'
    autoload :VERSION, 'doorkeeper/device_authorization_grant/version'

    # Namespace for device authorization request strategies
    module Request
      autoload :DeviceAuthorization, 'doorkeeper/device_authorization_grant/request/device_authorization'
    end

    # Namespace for device authorization requests and responses
    module OAuth
      autoload :DeviceAuthorizationRequest, 'doorkeeper/device_authorization_grant/oauth/device_authorization_request'
      autoload :DeviceAuthorizationResponse, 'doorkeeper/device_authorization_grant/oauth/device_authorization_response'
      autoload :DeviceCodeRequest, 'doorkeeper/device_authorization_grant/oauth/device_code_request'

      # Helper modules for device authorization
      module Helpers
        autoload :UserCode, 'doorkeeper/device_authorization_grant/oauth/helpers/user_code'
      end
    end

    # Namespace for ORM integrations
    module Orm
      autoload :ActiveRecord, 'doorkeeper/device_authorization_grant/orm/active_record'
    end

    # Namespace for Rails integrations
    module Rails
      autoload :Routes, 'doorkeeper/device_authorization_grant/rails/routes'
    end
  end

  # Doorkeeper Request namespace
  module Request
    autoload :DeviceCode, 'doorkeeper/request/device_code'
  end
end
