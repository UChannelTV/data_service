class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.integer :duration
      t.datetime :created_at
      t.timestamp :updated_at
      t.string :title, null: false
      t.text :description
      t.string :video_url
      t.text :tags
      t.string :category_id
      t.integer :status_id, null: false, default: 1
      t.text :other
    end

    add_index :videos, :status_id
    add_index :videos, :created_at
    add_index :videos, [:category_id, :created_at]
    add_index :videos, [:title, :category_id], :unique => true
    execute "ALTER TABLE videos change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE videos change `updated_at` `updated_at` timestamp"

  end
end
