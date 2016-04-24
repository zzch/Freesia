class JsonMessenger
  attr_accessor :result
  attr_accessor :message

  def initialize(message = '', success = true)
    @message = message
    @result = success ? 'success' : 'failure'
  end
end