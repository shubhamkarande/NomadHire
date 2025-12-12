class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :milestone, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.decimal :amount
      t.integer :provider
      t.string :provider_payment_id
      t.integer :status

      t.timestamps
    end
  end
end
