class MachinePulse < ActiveRecord::Base
  belongs_to :machine

  def self.response options = {}
    ActiveRecord::Base.transaction do
      if !options[:frame_number].blank? and !options[:frame_type].blank? and !options[:serial_number].blank? and !options[:gprs_intensity].blank? and !options[:json_params].blank?
        out_of_stock = options[:json_params][:OOS] == 'Y' ? true : false
        battery = options[:json_params][:BTY].to_i
        if machine = Machine.where(serial_number: options[:serial_number]).first
          existed_pulse = machine.pulses.where(frame_number: options[:frame_number]).first
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
            "#{options[:frame_number]},#{content.length},#{content}".tap do |response_data|
              create!(machine: machine, frame_number: options[:frame_number], frame_type: options[:frame_type], gprs_intensity: options[:gprs_intensity], out_of_stock: out_of_stock, battery: battery, response_data: response_data)
            end
          else
            existed_pulse.response_data
          end
        end
      end
    end
  end
end
