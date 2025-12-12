class CreateContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :contracts do |t|
      t.references :job, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.references :freelancer, null: false, foreign_key: { to_table: :users }
      t.decimal :total_amount
      t.integer :status

      t.timestamps
    end
  end
end
