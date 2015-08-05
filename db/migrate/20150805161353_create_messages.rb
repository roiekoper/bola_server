class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :content
      t.references :writer
      t.references :event
      t.timestamp :updated_at, null: false
    end
  end
end
