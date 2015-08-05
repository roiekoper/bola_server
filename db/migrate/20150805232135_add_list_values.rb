class AddListValues < ActiveRecord::Migration
  def change
    [
        [
            :event_status,
            [:accept, :maybe, :declined]
        ],
        [
            :message_status,
            [:delivered, :read]
        ]
    ].each do |kind, values|
      values.each { |value| List.create!(:kind => kind, :view => value) }
    end
  end
end
