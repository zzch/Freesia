class MachinePulse < ActiveRecord::Base
  belongs_to :machine

  def self.response params = []
    ActiveRecord::Base.transaction do
      if !params[:f].blank? and !params[:t].blank? and !params[:m].blank? and !params[:g].blank? and !params[:p].blank?
        inner_params = Hash[Base64.decode64(params[:p]).gsub(/[{}"]/, '').split(',').map{|param_pair| param_pair.split(':')}].symbolize_keys
        out_of_stock = inner_params[:OOS] == 'Y' ? true : false
        battery = inner_params[:BTY].to_i
        if machine = Machine.where(serial_number: params[:m]).first
          existed_pulse = machine.pulses.where(frame_number: params[:f]).first
          existed_pulse.destroy if !existed_pulse.blank? and where('created_at > ?', existed_pulse.created_at).count > 5
          if existed_pulse.blank? or existed_pulse.destroyed?
            machine.active(out_of_stock: out_of_stock, battery: battery)
            machine_dispensation = machine.dispensations.requested.order(:requested_at).first
            content = Base64.encode64(if machine_dispensation.blank?
              '1'
            else
              machine_dispensation.response!
              "#{machine_dispensation.id},#{machine_dispensation.amount}"
            end).strip
            "#{params[:f]},#{content.length},#{content}".tap do |response_data|
              create!(machine: machine, frame_number: params[:f], frame_type: params[:t], gprs_intensity: params[:g], out_of_stock: out_of_stock, battery: battery, response_data: response_data)
            end
          else
            existed_pulse.response_data
          end
        end
      end
    end
  end
end
