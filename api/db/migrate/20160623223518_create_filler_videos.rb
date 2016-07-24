class CreateFillerVideos < ActiveRecord::Migration
  def change
    create_table :filler_videos do |t|
      t.string :name, null: false
      t.string :source, null: false
      t.integer :duration, null: false
      t.string :video_url
      t.boolean :expired, default: false
      t.datetime :created_at
      t.timestamp :updated_at
    end

    add_index :filler_videos, :expired
    add_index :filler_videos, [:name, :source], :unique => true
    execute "ALTER TABLE filler_videos change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE filler_videos change `updated_at` `updated_at` timestamp"
  end
end
