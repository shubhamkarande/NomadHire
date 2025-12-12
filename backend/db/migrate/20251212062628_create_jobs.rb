class CreateJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :jobs do |t|
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.string :title
      t.text :description
      t.decimal :budget_min
      t.decimal :budget_max
      t.integer :budget_type
      t.date :deadline
      t.integer :status

      t.timestamps
    end
  end
end
