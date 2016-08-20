class OauthApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate

  private
  
  def authenticate
    if session[:user_id].nil?
      redirect_to new_session_path
    else
      user = User.find(session[:user_id])
      if !user.admin
        flash[:notice] = "You are not allowed to manage applications. Please log in with an admin account"
        redirect_to new_session_path
      end
    end
  end
end
