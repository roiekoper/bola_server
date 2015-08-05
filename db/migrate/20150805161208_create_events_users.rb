class CreateEventsUsers < ActiveRecord::Migration
  def change
    create_table :events_users do |t|
      t.references :user
      t.references :event
      t.boolean :admin, default: false, null: false
      t.references :status
    end
  end
end
