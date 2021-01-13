# frozen_string_literal: true

module Doorkeeper
  module DeviceAuthorizationGrant
    # Device authorization endpoint for OAuth 2.0 Device Authorization Grant.
    #
    # @see https://tools.ietf.org/html/rfc8628#section-3.1 RFC 8628, section 3.1
    class DeviceCodesController < ApplicationMetalController
      def create
        headers.merge!(authorize_response.headers)
        render(json: authorize_response.body, status: authorize_response.status)
      rescue Doorkeeper::Errors::DoorkeeperError => e
        handle_token_exception(e)
      end

      private

      def authorize_response
        @authorize_response ||= strategy.authorize
      end

      # @return [Request::DeviceAuthorization]
      def strategy
        @strategy ||= Request::DeviceAuthorization.new(server)
      end
    end
  end
end
