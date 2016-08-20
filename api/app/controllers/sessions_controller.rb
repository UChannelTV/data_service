class SessionsController < ApplicationController
  skip_before_filter :authenticate

  def new
  end

  def create
    @user = User.find_by(name: params[:name])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      flash.delete(:notice)
      redirect_to root_path
    else
      session.delete(:user_id)
      flash[:notice] = "You have entered incorrect name and/or password."
      render :new
    end
  end

  def destroy
    session.delete(:user_id)
    flash[:notice] = "You have been logged out"
    redirect_to new_session_path
  end
end
