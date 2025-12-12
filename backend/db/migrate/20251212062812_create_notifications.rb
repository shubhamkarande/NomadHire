class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind
      t.jsonb :payload
      t.boolean :read

      t.timestamps
    end
  end
end
