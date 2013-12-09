class CreateQuota < ActiveRecord::Migration
  def change
    create_table :quota do |t|
      t.string :uid, :unique => true
      t.string :value
    end
    add_index :quota, :uid, :unique => true
  end
end
