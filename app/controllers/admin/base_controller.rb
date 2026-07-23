module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin

    def current_actor
      :admin
    end

    private

    def authenticate_admin
      username = ENV["ADMIN_USERNAME"] || "admin"
      password = ENV["ADMIN_PASSWORD"] || "password"
      return if username.blank? || password.blank?

      authenticate_or_request_with_http_basic("Admin") do |given_user, given_password|
        secure_equal?(given_user, username) & secure_equal?(given_password, password)
      end
    end

    def secure_equal?(given, expected)
      ActiveSupport::SecurityUtils.secure_compare(
        Digest::SHA256.hexdigest(given.to_s),
        Digest::SHA256.hexdigest(expected.to_s)
      )
    end
  end
end
