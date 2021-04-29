# frozen_string_literal: true

module Doorkeeper
  module DeviceAuthorizationGrant
    module OAuth
      # IANA URN of the Device Authorization Grant Type.
      # @see https://tools.ietf.org/html/rfc8628#section-7.2 RFC 8628 - 7.2. OAuth URI Registration
      DEVICE_CODE = 'urn:ietf:params:oauth:grant-type:device_code'
      public_constant :DEVICE_CODE
    end
  end
end
