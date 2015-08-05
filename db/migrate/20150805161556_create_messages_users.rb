class CreateMessagesUsers < ActiveRecord::Migration
  def change
    create_table :messages_users do |t|
      t.references :message
      t.references :user
      t.references :status
    end
  end
end
