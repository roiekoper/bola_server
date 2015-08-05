class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :view
      t.string :kind
    end
  end
end
