# -*- encoding : utf-8 -*-
module V1
  class MachinesAPI < Grape::API
    resource :machines do
      desc '加球机心跳请求'
      post :pulse do
        header('Content-Type', 'text/html;charset=GBK')
        env['api.format'] = :txt
        status 200
        wrap_params = Hash[request.body.read.split('&').map{|param_pair| param_pair.split('=')}].symbolize_keys
        json_params = Hash[Base64.decode64(wrap_params[:p]).gsub(/[{}"]/, '').split(',').map{|param_pair| param_pair.split(':')}].symbolize_keys
        options = { frame_number: wrap_params[:f], frame_type: wrap_params[:t], serial_number: wrap_params[:m], gprs_intensity: wrap_params[:g], json_params: json_params }
        present(case json_params[:TYP]
        when '1' then MachinePulse.response(options)
        when '2' then MachineReport.response(options)
        end)
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
