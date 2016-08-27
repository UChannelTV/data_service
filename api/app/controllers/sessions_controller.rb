class SessionsController < ApplicationController
  skip_before_filter :authenticate

  def new
  end

  def create
    begin
      @user = User.from_omniauth(request.env['omniauth.auth'])
      session[:user_id] = @user.id
      flash.delete(:notice)
      redirect_to root_path
    rescue
      session.delete(:user_id)
      flash[:notice] = "There was an error while trying to authenticate you..."
      render :new
    end
  end

  def destroy
    session.delete(:user_id)
    flash[:notice] = "You have been logged out"
    redirect_to new_session_path
  end
end
