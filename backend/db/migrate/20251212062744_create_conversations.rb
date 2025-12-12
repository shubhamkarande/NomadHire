class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :participant_1, null: false, foreign_key: { to_table: :users }
      t.references :participant_2, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
