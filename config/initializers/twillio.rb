class BolaTwillio
  def initialize
    @client = Twilio::REST::Client.new(ENV['TWILLIO_ACCOUNT_SID'], ENV['TWILLIO_AUTH_TOKEN'])
  end

  def send_msg(to, body)
    @client.account.messages.create(
        :from => ENV['TWILLIO_FROM_NUMBER'],
        :to => to,
        :body => body
    )
  end
end