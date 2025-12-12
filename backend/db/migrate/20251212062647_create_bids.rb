class CreateBids < ActiveRecord::Migration[8.1]
  def change
    create_table :bids do |t|
      t.references :job, null: false, foreign_key: true
      t.references :freelancer, null: false, foreign_key: { to_table: :users }
      t.decimal :amount
      t.text :cover_letter
      t.integer :estimated_days
      t.integer :status

      t.timestamps
    end
  end
end
