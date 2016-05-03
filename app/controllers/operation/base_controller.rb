# -*- encoding : utf-8 -*-
class Operation::BaseController < ApplicationController
  layout 'operation'
  before_action :find_club
  before_action :authenticate
  before_action :find_progressing_tabs

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: lambda { |exception| render_error 500, exception }
    rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, with: lambda { |exception| render_error 404, exception }
  end

  protected
    def render_error status, exception
      ServiceException.create!(module: :operation, caller_id: (session['operator'].try(:[], 'id') || 0), name: exception.class.to_s, message: exception.message, backtrace: "<p>#{exception.backtrace.try(:join, '</p><p>')}</p>")
      render template: "operation/errors/error_#{status}", status: status
    end

    def find_club
      redirect_to public_welcome_path unless @current_club = Club.where(code: request.subdomain.gsub(/\.staging\Z/, '')).first
    end
    
    def authenticate
      begin
        @current_operator = @current_club.operators.find(session['operator'].try(:'[]', 'id'))
        @current_operator.role.permission_certificate(controller: controller_name, action: action_name)
      rescue ActiveRecord::RecordNotFound
        redirect_to sign_in_path 
      rescue PermissionDenied
        render template: "operation/errors/error_403", status: 403
      end
    end

    def find_progressing_tabs
      progressing_tabs_count = @current_club.tabs.progressing.count
      @progressing_tabs_count_badge = progressing_tabs_count > 9 ? '..' : progressing_tabs_count
      @progressing_tabs_count_label = progressing_tabs_count > 99 ? '99+' : progressing_tabs_count
      @dropdown_progressing_tabs = @current_club.tabs.progressing.limit(5)
    end
    
    def find_notifications
      @unread_notifications_count = OperatorNotification.by_operator(session['operator']['id']).unread.count
      @unread_notifications_count = '99+' if @unread_notifications_count > 99
      @dropdown_notifications = OperatorNotification.by_operator(session['operator']['id']).unread.latest.limit(5)
    end

    def club_and_operator_and_remarks
      { club_id: @current_club.id, operator_id: @current_operator.id, remarks: params[:remarks] }
    end
end
