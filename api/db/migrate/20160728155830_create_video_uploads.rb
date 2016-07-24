class CreateVideoUploads < ActiveRecord::Migration
  def change
    create_table :video_uploads do |t|
      t.integer :video_id
      t.string :host
      t.string :host_id
      t.boolean :enabled

      t.datetime :created_at
      t.timestamp :updated_at
    end

    add_index :video_uploads, :video_id
    add_index :video_uploads, [:host, :host_id], :unique => true
    execute "ALTER TABLE video_uploads change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE video_uploads change `updated_at` `updated_at` timestamp"
  end
end
