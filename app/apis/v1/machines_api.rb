# -*- encoding : utf-8 -*-
module V1
  class MachinesAPI < Grape::API
    resource :machines do
      desc '加球机心跳请求'
      post :pulse do
        header('Content-Type', 'text/html;charset=GBK')
        env['api.format'] = :txt
        status 200
        hash = Hash[request.body.read.split('&').map{|param_pair| param_pair.split('=')}].symbolize_keys
        Rails.logger.info "****** #{hash}"
        present MachinePulse.response(hash)
      end

      desc '加球机出球确认'
      post :confirm do
        header('Content-Type', 'text/html;charset=GBK')
        env['api.format'] = :txt
        status 200
        present MachineReport.response(Hash[request.body.read.split('&').map{|param_pair| param_pair.split('=')}].symbolize_keys)
      end

      params do
        requires :amount, type: Integer
      end
      get :simulate do
        present "交易ID：#{MachineDispensation.create!(machine_id: 1, club_id: 1, bay_id: 1, amount: params[:amount], requested_at: Time.now).id}"
      end
    end
  end
end
