# frozen_string_literal: true

require 'test_helper'

module Doorkeeper
  module DeviceAuthorizationGrant
    class DeviceGrantTest < ActiveSupport::TestCase
      setup do
        @application = Doorkeeper::Application.create!(
          name: 'Application',
          redirect_uri: 'https://example.com/application/redirect'
        )
      end

      test 'it has the correct table name' do
        assert_equal 'oauth_device_grants', DeviceGrant.table_name
      end

      test 'application_id must be present' do
        grant = DeviceGrant.new(model_attributes(application_id: nil))
        assert grant.invalid?
        assert grant.errors.include?(:application_id)
      end

      test 'expires_in must be present' do
        grant = DeviceGrant.new(model_attributes(expires_in: nil))
        assert grant.invalid?
        assert grant.errors.include?(:expires_in)
      end

      test 'device_code is generated before validation on model creation' do
        grant = DeviceGrant.new(model_attributes(device_code: nil))
        assert_nil grant.device_code
        grant.validate
        assert_not_nil grant.device_code
        assert grant.valid?
      end

      test 'device_code must be present' do
        grant = DeviceGrant.create!(model_attributes)
        grant.device_code = nil
        assert grant.invalid?
      end

      test 'user_code must be present if resource_owner_id is blank' do
        grant = DeviceGrant.new(model_attributes)
        assert grant.valid?
        grant.user_code = nil
        assert grant.invalid?
      end

      test 'resource_owner_id must be present if user_code is blank' do
        grant = DeviceGrant.new(
          model_attributes(resource_owner_id: 1, user_code: nil)
        )
        assert grant.valid?
        grant.resource_owner_id = nil
        assert grant.invalid?
      end

      test 'resource_owner_id and user_code cannot be both blank' do
        grant = DeviceGrant.new(model_attributes(user_code: nil))
        assert grant.invalid?
      end

      test 'resource_owner_id and user_code cannot be both present' do
        grant = DeviceGrant.new(model_attributes(resource_owner_id: 1))
        assert grant.invalid?
      end

      test 'the model is invalid if device_code is not unique' do
        model1 = DeviceGrant.create!(model_attributes)
        model2 = DeviceGrant.create!(model_attributes(user_code: 'bar'))
        model2.device_code = model1.device_code
        assert model2.invalid?
        assert model2.errors.include?(:device_code)
      end

      test 'the model is invalid if user_code is not unique' do
        model1 = DeviceGrant.create!(model_attributes)
        model2 = DeviceGrant.create!(model_attributes(user_code: 'bar'))
        model2.user_code = model1.user_code
        assert model2.invalid?
        assert model2.errors.include?(:user_code)
      end

      test '#expired? returns false if the expiration time has not come yet' do
        grant = DeviceGrant.new(model_attributes)
        assert_not grant.expired?
      end

      test '#expired? returns true if the expiration time has come' do
        grant = DeviceGrant.new(model_attributes(created_at: 301.seconds.ago))
        assert grant.expired?
      end

      test '.expired scope limits the results to expired grants only' do
        expired_grant = DeviceGrant.create!(
          model_attributes(created_at: 301.seconds.ago)
        )
        DeviceGrant.create!(model_attributes(user_code: 'bar'))
        results = DeviceGrant.expired.all
        assert_equal 1, results.length
        assert_equal expired_grant.id, results.first.id
      end

      test '.unexpired scope limits the results to unexpired grants only' do
        DeviceGrant.create!(model_attributes(created_at: 301.seconds.ago))
        unexpired_grant = DeviceGrant.create!(
          model_attributes(user_code: 'bar')
        )
        results = DeviceGrant.unexpired.all
        assert_equal 1, results.length
        assert_equal unexpired_grant.id, results.first.id
      end

      test 'with token hashing enabled, it holds a volatile plaintext device code when created' do
        enable_hash_token_secrets
        grant = DeviceGrant.create!(model_attributes)
        assert_instance_of String, grant.plaintext_device_code
        assert_equal transform_hashed_token(grant.plaintext_device_code), grant.device_code

        # Finder method only finds the hashed token
        found = DeviceGrant.find_by(device_code: grant.device_code)
        assert_equal grant, found
        assert_nil found.plaintext_device_code
        assert_equal grant.device_code, found.device_code
      end

      test 'with token hashing enabled, it does not find_by plain text tokens' do
        enable_hash_token_secrets
        grant = DeviceGrant.create!(model_attributes)
        assert_nil DeviceGrant.find_by(device_code: grant.plaintext_device_code)
      end

      test 'with token hashing enabled and having a plain text token, ' \
        'it does not provide lookups with either through by_token' do
        enable_hash_token_secrets
        grant = DeviceGrant.create!(model_attributes)
        # Assume we have a plain text token from before activating the option
        grant.update_column(:device_code, 'plain text token') # rubocop:disable Rails/SkipsModelValidations

        assert_nil DeviceGrant.by_device_code('plain text token')
        assert_nil DeviceGrant.by_device_code(grant.device_code)

        # And it does not touch the token
        grant.reload
        assert_equal 'plain text token', grant.device_code
      end

      test 'with token hashing and fallback lookup enabled, it upgrades a plain token when falling back to it' do
        enable_hash_token_secrets(fallback: :plain)
        grant = DeviceGrant.create!(model_attributes)
        # Assume we have a plain text token from before activating the option
        grant.update_column(:device_code, 'plain text token') # rubocop:disable Rails/SkipsModelValidations

        found = DeviceGrant.by_device_code('plain text token')
        assert_equal grant.id, found.id

        # Will find subsequently by hashing the token
        found = DeviceGrant.by_device_code('plain text token')
        assert_equal grant.id, found.id

        # And it modifies the token value
        grant.reload
        assert_not_equal 'plain text token', grant.device_code
        assert_nil DeviceGrant.find_by(device_code: 'plain text token')
        assert_not_nil DeviceGrant.find_by(device_code: grant.device_code)
      end

      private

      # @param attributes_overrides [Hash]
      # @return [Hash]
      def model_attributes(**attributes_overrides)
        {
          application_id: @application.id,
          resource_owner_id: nil,
          expires_in: 300.seconds,
          scopes: '',
          device_code: nil,
          user_code: 'foo',
          created_at: Time.now.utc,
          last_polling_at: nil
        }.merge(attributes_overrides)
      end

      def enable_hash_token_secrets(fallback: nil)
        Doorkeeper.configure do
          hash_token_secrets fallback: fallback
        end
      end

      # @param plain_secret [String] The plain secret input / generated
      # @return [String]
      def transform_hashed_token(plain_secret)
        Doorkeeper::SecretStoring::Sha256Hash.transform_secret(plain_secret)
      end
    end
  end
end
