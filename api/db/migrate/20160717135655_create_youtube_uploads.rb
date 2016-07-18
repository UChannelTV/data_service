class CreateYoutubeUploads < ActiveRecord::Migration
  def change
    create_table :youtube_uploads, id: false do |t|
      t.integer :uchannel_id
      t.string :youtube_id
      t.integer :duration
      t.datetime :published_at
      t.datetime :created_at
      t.timestamp :updated_at
      t.string :title
      t.text :description
      t.string :thumbnail_small
      t.string :thumbnail_medium
      t.string :thumbnail_large
      t.text :tags
      t.string :category_id
      t.string :live_broadcast_content
      t.string :upload_status
      t.string :privacy_status
      t.boolean :embeddable
    end

    add_index :youtube_uploads, :youtube_id, :unique => true
    add_index :youtube_uploads, :uchannel_id
    add_index :youtube_uploads, :published_at
    execute "ALTER TABLE youtube_uploads change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE youtube_uploads change `updated_at` `updated_at` timestamp"
  end
end
