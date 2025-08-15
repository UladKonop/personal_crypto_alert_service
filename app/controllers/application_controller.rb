class ApplicationController < ActionController::Base
  # Only apply CSRF protection for non-API requests
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  
  # For API requests, use null session
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
end
