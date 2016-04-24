# -*- encoding : utf-8 -*-
class Operation::SessionsController < Operation::BaseController
  skip_before_filter :authenticate#, :find_notifications
  layout null: true

  def new
  end

  def create
    begin
      operator = Operator.authenticate(club: @current_club, account: params[:account], password: params[:password])
      session[:operator] = { id: operator.id, name: operator.name }
      redirect_to dashboard_path
    rescue AccountDoesNotExist
      redirect_to sign_in_path, alert: '账号不存在，请重试'
    rescue ProhibitedOperator
      redirect_to sign_in_path, alert: '账号被禁用，无法登录'
    rescue IncorrectPassword
      redirect_to sign_in_path, alert: '密码不正确，请重试'
    end
  end

  def destroy
    session[:operator] = nil
    redirect_to sign_in_path
  end
end
