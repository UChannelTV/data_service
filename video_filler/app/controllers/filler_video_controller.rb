class FillerVideoController < ApplicationController
  def index
    limit = params[:limit].to_i
    limit = 100 if limit == 0
    @videos = FillerVideo.order(id: :desc).limit(limit)
  end

  def new
    @video, @url = FillerVideo.new, url_for(action: 'create')
  end

  def create
    @video, msg, code = FillerVideo._create(filler_video_params)
    flash[:notice] = msg
    if code == 201
      render 'show'
    else
      @url = url_for(action: 'create')
      render 'new'
    end
  end

  def show
    @video, msg, code = FillerVideo._find(params[:id])
    flash[:notice] = msg
  end

  def edit
    @url = url_for(action: 'update', id: params[:id])
    @video, msg, code = FillerVideo._find(params[:id])
    flash[:notice] = msg
  end

  def update
    @video, msg, code = FillerVideo._update(params[:id], filler_video_params)
    flash[:notice] = msg
    if code == 200
      render 'show'
    else
      @url = url_for(action: 'update', id: params[:id])
      render 'edit'
    end
  end

  def destroy
    video, msg, code = FillerVideo._destroy(params[:id])
    flash[:notice] = msg
    redirect_to action: 'index'
  end

  def match_search
  end

  def match_result
    @videos, @fields, msg = FillerTool.findFillerData(params["duration"], params["min_candidate"],
                                                     params["max_candidate"], params["allowed_gap"],
                                                     params["allow_duplicate"])
    flash[:notice] = msg
  end

  private

  def filler_video_params
    params.require(:filler_video).permit(:name, :source, :video_url, :length, :expired)
  end

end
