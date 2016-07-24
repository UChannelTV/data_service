class AddParentVideoToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :parent_video, :integer
  end
end
