class Event < ActiveRecord::Base
  has_many :events_users
  has_many :users, :through => :events_users
  has_many :messages

  has_attached_file :avatar, styles: {
                               square: '50x50#',
                               full: '350x350>'
                           }

  validates_presence_of :title, :description, :start_date, :location

  def create_message(message_opts)
    message = messages.create(message_opts)

    if message.errors.empty?
      writer = User.find_by_id(message.writer_id)
      writer_event = EventsUser.where(:user_id => message.writer_id,
                                      :event_id => message.event_id).
          joins(:user).select(:status_id).first

      firebase = Firebase::Client.new('https://boiling-torch-2188.firebaseio.com/')
      firebase.set("events/#{id}/#{message.id}", message.attributes.merge(
                                                   :writer_name => writer.try(:name).to_s,
                                                   :writer_status => List.find_by_id(writer_event.try(:status_id)).try(:view).to_s
                                               ))
      {}
    else
      {
          :success => false,
          :errs => message.errors.full_messages.join(', ')
      }
    end
  end
end
