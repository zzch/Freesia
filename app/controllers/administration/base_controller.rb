# -*- encoding : utf-8 -*-
class Administration::BaseController < ApplicationController
  layout 'administration'
  before_action :authenticate

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: lambda { |exception| render_error 500, exception }
    rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, with: lambda { |exception| render_error 404, exception }
  end

  protected
    def render_error status, exception
      ServiceException.create!(module: :operation, caller_id: (session['administrator'].try(:[], 'id') || 0), name: exception.class.to_s, message: exception.message, backtrace: "<p>#{exception.backtrace.try(:join, '</p><p>')}</p>")
      render template: "administration/errors/error_#{status}", status: status
    end
    
    def authenticate
      begin
        @current_administrator = Administrator.find(session['administrator'].try(:'[]', 'id'))
      rescue ActiveRecord::RecordNotFound
        redirect_to admin_sign_in_path 
      end
    end
end
