# frozen_string_literal: true

require 'securerandom'

module Doorkeeper
  module DeviceAuthorizationGrant
    module OAuth
      module Helpers
        # Simple module providing a method to generate a user code for device verification.
        module UserCode
          # @private
          # @return [Integer] virtually includes the range `0-9` _plus_ `a-z`
          BASE = 36
          private_constant :BASE

          # @private
          # @return [Integer]
          MAX_LENGTH = 8
          private_constant :MAX_LENGTH

          # @private
          # @return [Integer]
          MAX_NUMBER = BASE**MAX_LENGTH
          private_constant :MAX_NUMBER

          # Generates an alphanumeric user code for device verification, using `SecureRandom` generator.
          # @return [String]
          def self.generate
            SecureRandom
              .random_number(MAX_NUMBER)
              .to_s(BASE)
              .upcase
              .rjust(MAX_LENGTH, '0')
          end
        end
      end
    end
  end
end
