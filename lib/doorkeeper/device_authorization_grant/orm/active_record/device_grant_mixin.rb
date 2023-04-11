# frozen_string_literal: true

module Doorkeeper
  module DeviceAuthorizationGrant
    # Module mixin for Device Grant models.
    #
    # This is similar to Doorkeeper `AccessGrantMixin`, but specific for handling
    # OAuth 2.0 Device Authorization Grant.
    module DeviceGrantMixin
      extend ActiveSupport::Concern
      include ::Doorkeeper::Models::Expirable

      included do # rubocop:disable Metrics/BlockLength
        self.table_name = "#{table_name_prefix}oauth_device_grants#{table_name_suffix}"

        delegate :secret_strategy, :fallback_secret_strategy, to: :class

        belongs_to :application, class_name: Doorkeeper.configuration.application_class.to_s, optional: true

        before_validation :generate_device_code, on: :create

        validates :application_id, presence: true
        validates :expires_in, presence: true
        validates :device_code, presence: true, uniqueness: true

        validates :user_code, presence: true, uniqueness: true, if: -> { resource_owner_id.blank? }
        validates :user_code, absence: true, if: -> { resource_owner_id.present? }

        validates :resource_owner_id, presence: true, if: -> { user_code.blank? }
        validates :resource_owner_id, absence: true, if: -> { user_code.present? }
        validate :scopes_match_configured, if: :enforce_scopes?

        scope(
          :expired,
          lambda do
            exp_in = DeviceAuthorizationGrant.configuration.device_code_expires_in
            where('created_at <= :expiration_date', expiration_date: exp_in.seconds.ago)
          end
        )

        scope(
          :unexpired,
          lambda do
            exp_in = DeviceAuthorizationGrant.configuration.device_code_expires_in
            where('created_at > :expiration_date', expiration_date: exp_in.seconds.ago)
          end
        )
      end

      # ClassMethods
      module ClassMethods
        # Returns an instance of the DeviceGrant with specific device code
        # value.
        #
        # @param device_code [#to_s] device code value
        # @return [Doorkeeper::DeviceAuthorizationGrant::DeviceGrant, nil]
        #   DeviceGrant object, or nil if there is no record with such code
        def find_by_plaintext_device_code(device_code)
          device_code = device_code.to_s

          find_by(device_code: secret_strategy.transform_secret(device_code)) ||
            find_by_fallback_device_code(device_code)
        end

        alias by_device_code find_by_plaintext_device_code

        # Allow looking up previously plain device codes as a fallback IFF a
        # fallback strategy has been defined
        #
        # @param plain_secret [#to_s] plain secret value
        # @return [Doorkeeper::DeviceAuthorizationGrant::DeviceGrant, nil]
        #   DeviceGrant object or nil if there is no record with such code
        def find_by_fallback_device_code(plain_secret)
          return nil unless fallback_secret_strategy

          # Use the previous strategy to look up
          stored_code = fallback_secret_strategy.transform_secret(plain_secret)
          find_by(device_code: stored_code).tap do |resource|
            upgrade_fallback_value(resource, plain_secret) if resource
          end
        end

        # Allows to replace a plain value fallback, to avoid it remaining as
        # plain text.
        #
        # @param instance [Doorkeeper::DeviceAuthorizationGrant::DeviceGrant]
        #   An instance of this model with a plain value device code.
        # @param plain_secret [String] The plain secret to upgrade.
        def upgrade_fallback_value(instance, plain_secret)
          upgraded =
            secret_strategy.store_secret(instance, :device_code, plain_secret)
          instance.update(device_code: upgraded)
        end

        # Determines the secret storing transformer
        # Unless configured otherwise, uses the plain secret strategy
        def secret_strategy
          ::Doorkeeper.configuration.token_secret_strategy
        end

        # Determine the fallback storing strategy
        # Unless configured, there will be no fallback
        def fallback_secret_strategy
          ::Doorkeeper.configuration.token_secret_fallback_strategy
        end
      end

      # We keep a volatile copy of the raw device code for initial
      # communication.
      #
      # Some strategies allow restoring stored secrets (e.g. symmetric
      # encryption) while hashing strategies do not, so you cannot rely on
      # this value returning a present value for persisted device codes.
      def plaintext_device_code
        if secret_strategy.allows_restoring_secrets?
          secret_strategy.restore_secret(self, :device_code)
        else
          @raw_device_code
        end
      end

      private

      # Generates a device code value with UniqueToken class.
      #
      # @return [String] device code value
      def generate_device_code
        @raw_device_code = Doorkeeper::OAuth::Helpers::UniqueToken.generate
        secret_strategy.store_secret(self, :device_code, @raw_device_code)
      end

      def scopes_match_configured
        if scopes.present? && !Doorkeeper::OAuth::Helpers::ScopeChecker.valid?(
          scope_str: scopes.to_s,
          server_scopes: Doorkeeper.config.scopes
        )
          errors.add(:scopes, :not_match_configured)
        end
      end

      def enforce_scopes?
        Doorkeeper.config.enforce_configured_scopes?
      end
    end
  end
end
