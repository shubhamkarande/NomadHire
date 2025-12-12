# frozen_string_literal: true

class CreateDisputes < ActiveRecord::Migration[8.0]
  def change
    create_table :disputes do |t|
      t.references :milestone, null: false, foreign_key: true
      t.references :raised_by, null: false, foreign_key: { to_table: :users }
      t.references :resolved_by, foreign_key: { to_table: :users }
      
      t.text :reason, null: false
      t.text :evidence
      t.integer :status, default: 0, null: false
      t.text :admin_notes
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :disputes, :status
    add_index :disputes, :created_at
  end
end
