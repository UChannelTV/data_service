class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.boolean :admin

      t.timestamps null: false
    end
    add_index :users, :name

    execute "ALTER TABLE users change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE users change `updated_at` `updated_at` timestamp;"
  end
end
