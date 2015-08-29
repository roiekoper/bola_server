class Event < ActiveRecord::Base
  has_many :events_users
  has_many :users, :through => :events_users
  has_many :messages

  has_attached_file :avatar, styles: {
                               square: '50x50#',
                               full: '350x350>'
                           }

  validates_presence_of :title, :description, :start_date, :location
  validates_attachment_content_type :avatar, :content_type => %w(image/jpg image/jpeg image/png image/gif)

  def to_serialize(user)
    Event.where(id: id).to_serialize(user).first
  end

  def self.to_serialize(user)
    joins(:users).where(:events_users => {:user_id => user.id}).
        select(column_names - ['id'] + ['events.id id'] + %w(events_users.admin events_users.status_id)).
        map do |event|
      event.slice(*%i[id title description location]).merge(
          :admin => event.admin,
          :status => List.find_by_id(event.status_id).try(:view),
          :start_date => event.start_date.try(:long_format),
          :end_date => event.end_date.try(:long_format),
          avatar: event.avatar.url(:original),
          img_square: event.avatar.url(:square),
          img_full: event.avatar.url(:full),
          :created_at => event.created_at.try(:long_format))
    end
  end

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
      Ionic::PushService.new.notify(message.event.users.pluck(:user_token), {alert: message.content})
      {}
    else
      {
          :success => false,
          :errs => message.errors.full_messages.join(', ')
      }
    end
  end
end
