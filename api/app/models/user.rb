class User < ActiveRecord::Base
  validates :name, presence: true

  def self.from_omniauth(auth_hash)
    user = find_or_create_by(name: auth_hash['info']['name'])
    user.save!
    user
  end

  def self.external_name
    "User"
  end

  def self.external_params(params)
    retVal = params.permit(:name, :admin)
  end
end
