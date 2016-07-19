# -*- encoding : utf-8 -*-
class Administration::SessionsController < Administration::BaseController
  skip_before_filter :authenticate, :find_progressing_tabs
  layout null: true

  def new
  end

  def create
    begin
      administrator = Administrator.authenticate(account: params[:account], password: params[:password])
      session[:administrator] = { id: administrator.id }
      redirect_to admin_dashboard_path
    rescue AccountDoesNotExist
      redirect_to admin_sign_in_path, alert: '账号不存在，请重试'
    rescue ProhibitedAdministrator
      redirect_to admin_sign_in_path, alert: '账号被禁用，无法登录'
    rescue IncorrectPassword
      redirect_to admin_sign_in_path, alert: '密码不正确，请重试'
    end
  end

  def destroy
    session[:administrator] = nil
    redirect_to sign_in_path
  end
end
