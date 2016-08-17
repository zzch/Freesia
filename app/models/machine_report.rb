class MachineReport < ActiveRecord::Base
  belongs_to :machine

  def self.response options = {}
    ActiveRecord::Base.transaction do
      if !options[:frame_number].blank? and !options[:frame_type].blank? and !options[:serial_number].blank? and !options[:gprs_intensity].blank? and !options[:json_params].blank?
        dispensation_id, error_code = options[:json_params][:TID], options[:json_params][:EC]
        success = options[:json_params][:OB] == 'Y' ? true : false
        if machine = Machine.where(serial_number: options[:serial_number]).first and machine.reports.where(frame_number: options[:frame_number]).blank? and machine_dispensation = machine.dispensations.where(id: dispensation_id).first
          create!(machine: machine, frame_number: options[:frame_number], frame_type: options[:frame_type], gprs_intensity: options[:gprs_intensity], machine_dispensation: machine_dispensation, success: success, error_code: error_code)
          machine.up!
          machine_dispensation.confirm! if success
          content = Base64.encode64('1').strip
          "#{options[:frame_number]},#{content.length},#{content}"
        end
      end
    end
  end
end
