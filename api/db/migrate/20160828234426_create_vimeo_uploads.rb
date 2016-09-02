class CreateVimeoUploads < ActiveRecord::Migration
  def change
    create_table :vimeo_uploads, id: false do |t|
      t.string :vimeo_id
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
      t.integer :width
      t.integer :height
      t.string :embed_privacy
      t.string :channel_id
      t.boolean :expired, default: false
    end

    add_index :vimeo_uploads, :vimeo_id, :unique => true
    add_index :vimeo_uploads, :published_at
    add_index :vimeo_uploads, :channel_id
    execute "ALTER TABLE vimeo_uploads change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE vimeo_uploads change `updated_at` `updated_at` timestamp"
  end
end
