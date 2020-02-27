class ApplicationController < ActionController::Base
    def fetch_header
        {"Authorization": Rails.application.credentials.canvas[:authorization_key]}
    end

    skip_before_action :verify_authenticity_token
end
