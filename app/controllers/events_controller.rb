class EventsController < ApplicationController
  def index
    p current_user.present?
    response = (current_user ? current_user.json_events : { :msg => t('app.user_disconnected') }).
        merge(:success => current_user.present?)
    general_response response
  end
end
