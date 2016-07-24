class ParentVideo < ActiveRecord::Base
  validates :id, :parent_id, presence: true

  def self.external_name
    "Parent video"
  end

  def self.external_params(params)
    params.permit(:id, :parent_id)
  end
end
