class CreateVideoStatuses < ActiveRecord::Migration
  def change
    create_table :video_statuses do |t|
      t.string :status
    end
  end
end
