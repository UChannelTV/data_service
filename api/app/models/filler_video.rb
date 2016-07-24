class FillerVideo < ActiveRecord::Base
  validates :name, :source, presence: true
  validates :duration, numericality: {greater_than: 0, message: "must be a positive interger"} 

  def self.external_name
    "Filler video"
  end

  def self.external_params(params)
    params.permit(:name, :source, :video_url, :duration, :expired)
  end
end

