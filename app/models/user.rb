class User < ActiveRecord::Base
  has_many :events_users
  has_many :events, :through => :events_users
  has_attached_file :avatar, styles: {
                               thumb: '25x25#',
                               square: '50x50#',
                               full: '350x350>'
                           }

  validates_presence_of :phone_number, :phone_prefix, :uuid
  validates_length_of :phone_prefix, :maximum => 3
  validates_length_of :name, :minimum => 1, :allow_blank => true
  validates_attachment_content_type :avatar, :content_type => %w(image/jpg image/jpeg image/png image/gif)

  before_create :send_code

  # create random verify code between 1000 - 9999 & send sms with verify_code to user phone number with Twillio
  def send_code
    self.verify_code = rand(1000..9999)

    begin
      BolaTwillio.new.msg("+#{phone_prefix}#{phone_number}", "Your code: #{verify_code}")
    rescue Exception => e
      errors.add :base, :verified_failed
    end
  end

  def to_serialize
    {
        id: id,
        avatar: avatar.url(:original),
        img_thumb: avatar.url(:thumb),
        img_square: avatar.url(:square),
        img_full: avatar.url(:full),
        name: name,
        verified: verified?
    }
  end

  def json_events
    {:events => Event.to_serialize(self)}
  end
end
