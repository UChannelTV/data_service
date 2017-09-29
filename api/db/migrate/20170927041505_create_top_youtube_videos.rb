class CreateTopYoutubeVideos < ActiveRecord::Migration
  def change
    create_table :top_youtube_videos do |t|
      t.string :category_id
      t.string :tag
      t.text :youtube_ids
      t.datetime :created_at
      t.timestamp :updated_at
    end

    add_index :top_youtube_videos, [:category_id, :tag], :unique => true
    add_index :top_youtube_videos, [:category_id, :tag, :created_at]
    execute "ALTER TABLE top_youtube_videos change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE top_youtube_videos change `updated_at` `updated_at` timestamp"
  end
end
