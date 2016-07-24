require_relative './admin_controller'

class FillerVideoAdminController < AdminController 
  def initialize
    super(FillerVideo)
  end
  
  def match_search
  end

  def match_result
    @videos, @fields, msg = FillerTool.findFillerData(params["duration"], params["min_candidate"],
                                                      params["max_candidate"], params["allowed_gap"],
                                                      params["allow_duplicate"])
    flash[:notice] = msg.to_json if !msg.nil?
  end
end
