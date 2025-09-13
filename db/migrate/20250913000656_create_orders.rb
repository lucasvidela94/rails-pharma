class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :external_id
      t.string :status
      t.decimal :total
      t.text :data
      t.boolean :synced

      t.timestamps
    end
    add_index :orders, :external_id, unique: true
  end
end
