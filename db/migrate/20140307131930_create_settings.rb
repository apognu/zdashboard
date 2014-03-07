class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :key, :unique => true
      t.string :value
    end
    add_index :settings, :key, :unique => true
  end
end
