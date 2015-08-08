class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :uuid
      t.integer :phone_prefix, limit: 3
      t.integer :phone_number
      t.integer :verify_code, limit: 4
      t.boolean :verified, default: false, null: false
      t.attachment :avatar
      t.timestamps null: false
    end
  end
end
