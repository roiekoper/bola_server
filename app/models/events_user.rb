class EventsUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  def update_status(status_view)
    update_attributes :status_id => List.find_by_view(status_view).try(:id)
  end
end
