class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.integer :duration
      t.datetime :created_at
      t.timestamp :updated_at
      t.string :title
      t.string :description
      t.string :video_url
      t.string :tags
      t.string :category_id
      t.string :status
    end

    add_index :videos, :status
    add_index :videos, :created_at
    add_index :videos, [:category_id, :created_at]
    execute "ALTER TABLE videos change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE videos change `updated_at` `updated_at` timestamp"

  end
end
