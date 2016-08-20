class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_action :verify_authenticity_token, if: :json_request?

  before_filter :allow_cors, :authenticate

  protected

  def json_request?
    return true if request.path.start_with?("/api/")
    "application/json".eql?(request.content_type.to_s.downcase)
  end

  def json_rsp(data, msg, code, match)
    if code == match
      render json: data, status: code
    else
      render json: msg, status: code
    end
  end

  def allow_cors
    headers['Access-Control-Allow-Origin'] = '*'
  end

  def authenticate
    if session[:user_id].nil? && !doorkeeper_token.nil?
      session[:user_id] = doorkeeper_token.resource_owner_id
    end
    redirect_to new_session_path if session[:user_id].nil?
  end

  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user
end
