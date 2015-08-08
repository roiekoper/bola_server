class EventsController < ApplicationController
  def index
    response = (current_user ? current_user.json_events : { :msg => t('app.user_disconnected') }).
        merge(:success => current_user.present?)
    general_response response
  end

  def create
    event = Event.create(params.permit(:title, :description, :start_date, :end_date, :location))

    if event.errors.empty?
      EventsUser.create(:user_id => current_user.id,
                        :event_id => event.id,
                        :admin => true)
    end

    general_response :success => event.errors.empty?,
                     :errs => event.errors.full_messages.join(', '),
                     :event_id => event.id
  end
end
