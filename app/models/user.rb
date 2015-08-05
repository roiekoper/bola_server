class User < ActiveRecord::Base
  before_create :send_code

  def send_code
    self.verify_code = 1000 + rand(8999)

    # put your own credentials here
    account_sid = 'ACbf19f26af86c702e4973df19b68fee91'
    auth_token = '132d2cc5489f22ec99af11fdb99270f3'

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new(account_sid, auth_token)

    @client.account.messages.create(
                                        :from => '+14796897174',
                                        :to => "+#{phone_prefix}#{phone_number}",
                                        :body => "Your code: #{verify_code}"
                                    )
  end
end
