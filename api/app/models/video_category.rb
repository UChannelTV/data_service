class VideoCategory < ActiveRecord::Base
  validates :name, :english_name, presence: true

  def self.external_name
    "Video cateory"
  end

  def self.external_params(params)
    params.permit(:name, :english_name, :qr_code)
  end
end
