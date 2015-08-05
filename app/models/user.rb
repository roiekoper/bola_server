class User < ActiveRecord::Base
  has_many :events_users
  has_many :events, :through => :events_users

  validates_presence_of :phone_number, :phone_prefix, :uuid
  validates_length_of :phone_prefix, :maximum => 3

  before_create :send_code

  # create random verify code between 1000 - 9999 & send sms with verify_code to user phone number with Twillio
  def send_code
    self.verify_code = rand(1000..9999)

    @client = Twilio::REST::Client.new(ACCOUNT_SID, AUTH_TOKEN)
    begin
      @client.account.messages.create(
          :from => FROM_NUMBER,
          :to => "+#{phone_prefix}#{phone_number}",
          :body => "Your code: #{verify_code}"
      )
    rescue Exception => e
      errors.add :base, :verified_failed
    end
  end

  def json_events
    {
        :events => Event.joins(:users).where(:events_users => { :user_id => id }).
            select(Event.column_names + %w(events_users.admin events_users.status_id)).
            map do |event|
          event.slice(*%i[ title description location]).merge(
              :admin => event.admin,
              :status => List.find_by_id(event.status_id),
              :start_date => event.start_date.try(:long_format),
              :end_date => event.end_date.try(:long_format),
              :created_at => event.created_at.try(:long_format))
        end
    }
  end
end
