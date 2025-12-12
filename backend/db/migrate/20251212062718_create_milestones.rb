class CreateMilestones < ActiveRecord::Migration[8.1]
  def change
    create_table :milestones do |t|
      t.references :contract, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.decimal :amount
      t.date :due_date
      t.integer :status
      t.string :payment_transaction_id

      t.timestamps
    end
  end
end
