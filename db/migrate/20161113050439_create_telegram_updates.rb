class CreateTelegramUpdates < ActiveRecord::Migration
  def change
    create_table :telegram_updates, id: false do |t|
      t.integer :id, :limit => 8, primary_key: true
      t.datetime :created_at, null: false
    end
  end
end

