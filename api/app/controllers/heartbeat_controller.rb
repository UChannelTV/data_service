class HeartbeatController < ApplicationController
  skip_before_filter :authenticate

  def index
    render :text => "OK"
  end
end
