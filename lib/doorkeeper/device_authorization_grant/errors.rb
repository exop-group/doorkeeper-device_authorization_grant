# frozen_string_literal: true

module Doorkeeper
  module DeviceAuthorizationGrant
    module Errors
      # The authorization request is still pending as the end user hasn't
      # yet completed the user-interaction steps.
      #
      # The client SHOULD repeat the access token request to the token endpoint
      # (a process known as polling). Before each new request, the client MUST
      # wait at least the number of seconds specified by the "interval"
      # parameter of the device authorization response, or 5 seconds if none
      # was provided, and respect any increase in the polling interval
      # required by the "slow_down" error.
      class AuthorizationPending < ::Doorkeeper::Errors::DoorkeeperError
        def type
          :authorization_pending
        end
      end

      # A variant of "authorization_pending", the authorization request is
      # still pending and polling should continue, but the interval MUST be
      # increased by 5 seconds for this and all subsequent requests.
      class SlowDown < ::Doorkeeper::Errors::DoorkeeperError
        def type
          :slow_down
        end
      end

      # The "device_code" has expired, and the device authorization session has
      # concluded.
      #
      # The client MAY commence a new device authorization request but SHOULD
      # wait for user interaction before restarting to avoid unnecessary
      # polling.
      class ExpiredToken < ::Doorkeeper::Errors::DoorkeeperError
        def type
          :expired_token
        end
      end
    end
  end
end
