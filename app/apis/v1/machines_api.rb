# -*- encoding : utf-8 -*-
module V1
  class MachinesAPI < Grape::API
    resource :machines do
      desc '加球机心跳请求'
      post :pulse do
        result = MachinePulse.response(Hash[request.body.read.split('&').map{|param_pair| param_pair.split('=')}].symbolize_keys)
        Rails.logger.info result
        present result
      end

      desc '加球机出球确认'
      post :confirm do
        
        present 'test'
      end
    end
  end
end
