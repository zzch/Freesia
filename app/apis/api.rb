# -*- encoding : utf-8 -*-
module DocFormatter
  def self.call object, env
    object.to_json
  end
end

module ErrorFormatter
  def self.call message, backtrace, options, env
    if message.to_s =~ /\d{5}/
      if message < 20000
        { error_code: message, message: APIException.message(message) }.to_json
      else
        { exception_code: message, message: APIException.message(message) }.to_json
      end
    else
      { error_code: 10000, message: message }.to_json
    end
  end
end

class API < Grape::API
  version :v1
  format :json
  prefix :api
  error_formatter :json, ErrorFormatter
  content_type :txt, 'application/text; charset=gbk'
  content_type :json, 'application/json; charset=utf8'

  helpers do
    def api_error_or_exception code
      if code < 20000
        error!(code, APIError.send("code_#{code}")[:status])
      else
        error!(code, 200)
      end
    end

    def api_success
      { result: :success }
    end

    def authenticate!
      params[:token] = User.where(phone: 13911320927).first.token if Rails.env == 'development' and params[:token] == 'test'
      api_error_or_exception(10002) if params[:token].nil? or (@current_user = User.authorize(params[:token])).nil?
    end

    def find_current_club
      params[:club_uuid] = Club.where(code: 'isports').first.uuid if Rails.env == 'development' and params[:club_uuid] == 'test'
      begin
        @current_club = Club.find_uuid(params[:club_uuid])
      rescue ActiveRecord::RecordNotFound
        api_error_or_exception(10003)
      end
    end
  end

  mount V1::MachinesAPI
  
  namespace do
    before do
      authenticate!
    end

  end

  namespace :doc do
    formatter :json, DocFormatter 
    add_swagger_documentation api_version: 'v1'
  end
end