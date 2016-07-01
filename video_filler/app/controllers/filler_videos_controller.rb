class FillerVideosController < ApplicationController
  include FillerTool

  def index
    limit = params[:limit].to_i
    limit = 100 if limit == 0
    render :json => FillerVideo.order(id: :desc).limit(limit)
  end

  def create
    data, msg, code = FillerVideo._create(filler_video_params)
    rsp(data, msg, code, 201)
  end

  def show
    data, msg, code = FillerVideo._find(params[:id])
    rsp(data, msg, code, 200)
  end

  def update
    data, msg, code = FillerVideo._update(params[:id], filler_video_params)
    rsp(data, msg, code, 200)
  end

  def destroy
    data, msg, code = FillerVideo._destroy(params[:id])
    render json: {"msg" => msg}, status: code
  end

  def find
    data, msg, code = FillerTool.findFillers(params["duration"], params["min_candidate"],
                                        params["max_candidate"], params["allowed_gap"],
                                        params["allow_duplicate"])
    rsp(data,msg, code, 200)
  end

  private

  def rsp(data, msg, code, match)
    if code == match
      render json: data, status: code
    else
      render json: {"error" => msg}, status: code
    end
  end


  def filler_video_params
    params.require(:filler_video).permit(:name, :source, :video_url, :length)
  end
end
