class User < ActiveRecord::Base
  has_secure_password
  validates :name, presence: true

  def self.external_name
    "User"
  end

  def self.external_params(params)
    retVal = params.permit(:name, :password, :password_confirmation, :admin)
  end
end
