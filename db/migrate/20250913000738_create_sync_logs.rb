class CreateSyncLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :sync_logs do |t|
      t.string :sync_type
      t.string :status
      t.integer :orders_processed
      t.integer :orders_synced
      t.text :error_details
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :duration

      t.timestamps
    end
  end
end
