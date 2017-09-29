class CreateActiveLabels < ActiveRecord::Migration
  def change
    create_table :active_labels, id: false do |t|
      t.string :task
      t.string :label
      t.datetime :created_at
      t.timestamp :updated_at
    end

    add_index :active_labels, :task, :unique => true
    execute "ALTER TABLE vimeo_uploads change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE vimeo_uploads change `updated_at` `updated_at` timestamp"
  end
end
