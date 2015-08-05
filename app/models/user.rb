class User < ActiveRecord::Base
  before_create :send_code

  # create random verify code between 1000 - 9999 & send sms with verify_code to user phone number with Twillio
  def send_code
    self.verify_code = rand(1000..9999)

    @client = Twilio::REST::Client.new(ACCOUNT_SID, AUTH_TOKEN)
    @client.account.messages.create(
                                        :from => FROM_NUMBER,
                                        :to => "+#{phone_prefix}#{phone_number}",
                                        :body => "Your code: #{verify_code}"
                                    )
  end
end
