class UsersController < AdminController
  before_filter :verify_admin
  def initialize
    super(User)
  end

  private
  def verify_admin
    if !current_user.admin
      flash[:notice] = "You are not allowed to add a new user. Please log in with an admin account"
      redirect_to new_session_path
    end
    @new_user = User.new
  end
end
