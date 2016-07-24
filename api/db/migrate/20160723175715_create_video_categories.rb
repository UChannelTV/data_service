class CreateVideoCategories < ActiveRecord::Migration
  def change
    create_table :video_categories do |t|
      t.string :name
      t.string :english_name
      t.string :qr_code

      t.datetime :created_at
      t.timestamp :updated_at
    end

    add_index :video_categories, :name, :unique => true
    add_index :video_categories, :english_name, :unique => true
    execute "ALTER TABLE video_categories change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE video_categories change `updated_at` `updated_at` timestamp"
  end
end
