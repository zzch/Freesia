# -*- encoding : utf-8 -*-
class APIException
  @contents = {
    10001 => { status: 404, message: '数据未找到' },
    10002 => { status: 401, message: 'Token失效' },
    10003 => { status: 403, message: '非法访问' },
    20001 => { message: '用户不存在' },
    20002 => { message: '用户未激活' },
    20003 => { message: '验证码不正确' },
    20004 => { message: '重复预约' },
    20005 => { message: '无效的状态' },
    20006 => { message: '课程预约已满' },
    20007 => { message: '请求过于频繁' },
  }

  class << self
    def method_missing(sym, *args, &block)
      if sym =~ /^code_\d{5}$/
        @contents[sym.to_s.scan(/^code_(\d{5})$/)[0][0].to_i].tap do |content|
          content.merge!(status: 200) unless content.has_key?(:status)
        end
      else
        super(sym, *args, &block)
      end
    end

    def message(code)
      @contents[code][:message]
    end
  end
end
