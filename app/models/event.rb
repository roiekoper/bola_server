class Event < ActiveRecord::Base
  has_many :events_users
  has_many :users, :through => :events_users

  validates_presence_of :title, :description, :start_date, :location
end
