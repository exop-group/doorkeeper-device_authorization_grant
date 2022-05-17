# frozen_string_literal: true

module Doorkeeper
  module DeviceAuthorizationGrant
    # Model class, similar to Doorkeeper `AccessGrant`, but specific for
    # handling OAuth 2.0 Device Authorization Grant.
    class DeviceGrant < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord Doorkeeper models inherit from ActiveRecord::Base.
      include DeviceGrantMixin

      # @!attribute application_id
      #   @return [Integer]

      # @!attribute resource_owner_id
      #   @return [Integer, nil]

      # @!attribute expires_in
      #   @return [Integer]

      # @!attribute scopes
      #   @return [String]

      # @!attribute device_code
      #   @return [String]

      # @!attribute user_code
      #   @return [String, nil]

      # @!attribute created_at
      #   @return [Time]

      # @!attribute last_polling_at
      #   @return [Time, nil]
    end
  end
end
