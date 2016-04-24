module PortoHelper
  def porto_arat attribute
    t "activerecord.attributes.#{attribute}"
  end

  def porto_amat attribute
    t "activemodel.attributes.#{attribute}"
  end

  def porto_nav name, icon, controllers = [], remote_url = nil, &block
    raw(if block_given?
      "<li class=\"nav-parent#{' nav-expanded nav-active' if controllers.include?(controller_name)}\"><a><i class=\"#{icon}\" aria-hidden=\"true\"></i> <span>#{name}</span></a><ul class=\"nav nav-children\">#{capture(&block)}</ul></li>"
    else
      "<li#{raw(' class="nav-active"') if controllers.include?(controller_name)}>#{link_to raw("<i class=\"#{icon}\" aria-hidden=\"true\"></i> <span>#{name}</span>"), remote_url}</li>"
    end)
  end

  def porto_date date
    date.try(:strftime, '%Y-%m-%d') || '无'
  end

  def porto_time date
    date.try(:strftime, '%H:%M') || '无'
  end

  def porto_datetime datetime
    datetime.try(:strftime, '%Y-%m-%d %H:%M') || '无'
  end

  def porto_boolean boolean
    boolean ? '是' : '否'
  end

  def porto_flash
    dismiss_btn = '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>'
    if flash[:alert]
      raw "<div class=\"alert alert-danger\">#{dismiss_btn}#{flash[:alert]}</div>"
    elsif flash[:notice]
      raw "<div class=\"alert alert-success\">#{dismiss_btn}#{flash[:notice]}</div>"
    end
  end

  def porto_paginate model
    paginate model
  end

  def porto_hour_options
    options_for_select (6..18).map{|hour| ["#{hour.to_s.rjust(2, '0')}时", hour]}
  end

  def porto_minute_options
    options_for_select (0..59).map{|minute| ["#{minute.to_s.rjust(2, '0')}分", minute]}
  end

  def porto_price price
    "#{number_with_precision(price, precision: 2, strip_insignificant_zeros: true)}元" unless price.blank?
  end

  def porto_seconds total_seconds
    minutes = ((total_seconds / 60) % 60).round
    hours = (total_seconds / 60 / 60).floor
    (hours.zero? ? '' : "#{hours}小时") + (minutes.zero? ? '不足一分钟' : "#{minutes}分钟")
  end

  def porto_day date
    if Time.now.beginning_of_day <= date and Time.now.end_of_day >= date then '今天'
    elsif Time.now.tomorrow.beginning_of_day <= date and Time.now.tomorrow.end_of_day >= date then '明天'
    else '后天'
    end
  end

  def porto_wday wday
    case wday
    when 0 then '星期日'
    when 1 then '星期一'
    when 2 then '星期二'
    when 3 then '星期三'
    when 4 then '星期四'
    when 5 then '星期五'
    when 6 then '星期六'
    end
  end

  def porto_month months
    years = months / 12
    months = months % 12
    "#{"#{years}年" unless years.zero?}#{"#{months}月" unless months.zero?}"
  end
end
