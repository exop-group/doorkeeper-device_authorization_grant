# frozen_string_literal: true

module Doorkeeper
  module DeviceAuthorizationGrant # rubocop:disable Style/Documentation
    def self.configure(&block)
      if ::Doorkeeper.configuration.orm != :active_record
        raise UnsupportedConfiguration, 'Doorkeeper::DeviceAuthorizationGrant only supports ActiveRecord ORM'
      end

      @config = Config::Builder.new(Config.new, &block).build
    end

    # @return [::Doorkeeper::DeviceAuthorizationGrant::Config]
    def self.configuration
      @config || (raise MissingConfiguration)
    end

    # Error raised in case of missing configuration
    class MissingConfiguration < StandardError
      def initialize
        super(
          'Configuration for Doorkeeper::DeviceAuthorizationGrant missing. ' \
            'Do you have Doorkeeper::DeviceAuthorizationGrant initializer?'
        )
      end
    end

    # Error raised when an unsupported configuration parameter is encountered
    class UnsupportedConfiguration < StandardError; end

    # Configuration model for Doorkeeper DeviceAuthorizationGrant
    class Config
      class Builder < Doorkeeper::Config::AbstractBuilder
      end

      def self.builder_class
        Config::Builder
      end

      extend Doorkeeper::Config::Option

      # @!attribute [r] device_code_polling_interval
      #   Minimum device code polling interval expected from the client, expressed in seconds.
      #   @return [Integer]
      option :device_code_polling_interval, default: 5

      # @!attribute [r] device_code_expires_in
      #   Device code expiration time, in seconds.
      #   @return [Integer]
      option :device_code_expires_in, default: 300

      # @!attribute [r] device_grant_class
      #   Customizable reference to the DeviceGrant model.
      #   @return [String]
      option :device_grant_class, default: 'Doorkeeper::DeviceAuthorizationGrant::DeviceGrant'

      # @!attribute [r] user_code_generator
      #   Reference to a model (or class) for user code generation.
      #
      #   It must implement a `.generate` method, which can be invoked without
      #   arguments, to obtain a String user code value.
      #   @return [String]
      option :user_code_generator, default: 'Doorkeeper::DeviceAuthorizationGrant::OAuth::Helpers::UserCode'

      # @!attribute [r] verification_uri
      #   A Proc returning the end-user verification URI on the authorization server.
      #   @return [Proc]
      option :verification_uri, default: ->(host_name) { "#{host_name}/oauth/device" }

      # @!attribute [r] verification_uri_complete
      #   A Proc returning the verification URI that includes the "user_code"
      #   (or other information with the same function as the "user_code"), which is
      #   designed for non-textual transmission. This is optional, so the Proc can
      #   also return `nil`.
      #   @return [Proc]
      option(
        :verification_uri_complete,
        default: lambda do |verification_uri, _host_name, device_grant|
          "#{verification_uri}?user_code=#{CGI.escape(device_grant.user_code)}"
        end
      )

      # @return [Class]
      def device_grant_model
        @device_grant_model ||= device_grant_class.constantize
      end

      # @return [Class, Module]
      def user_code_generator_class
        @user_code_generator_class ||= user_code_generator.constantize
      end
    end
  end
end
