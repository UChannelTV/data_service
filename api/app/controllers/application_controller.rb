class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_action :verify_authenticity_token, if: :json_request?

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
end
