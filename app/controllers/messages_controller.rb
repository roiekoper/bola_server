class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    event = Event.find_by_id(params.permit(:event_id)[:event_id])

    general_response(if event
                       event.create_message(:content => params.permit(:content)[:content],
                                            :writer_id => current_user.id,
                                            :event_id => event.id)
                     else
                       { :errs => t('app.event_failure') }
                     end)
  end
end
