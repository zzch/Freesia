# -*- encoding : utf-8 -*-
class UserPortraitUploader < BaseUploader
  version :w150_h150_fl_q50 do
    process quality: 50
    process resize_to_fill: [150, 150]
  end

  version :w500_h500_fl_q80 do
    process quality: 80
    process resize_to_fill: [500, 500]
  end
end