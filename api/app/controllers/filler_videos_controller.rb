require_relative './api_controller'

class FillerVideosController < ApiController
  include FillerTool

  def initialize
    super(FillerVideo)
  end

  def find
    data, msg, code = FillerTool.findFillers(params["duration"], params["min_candidate"],
                                             params["max_candidate"], params["allowed_gap"],
                                             params["allow_duplicate"])
    json_rsp(data,msg, code, 200)
  end
end
