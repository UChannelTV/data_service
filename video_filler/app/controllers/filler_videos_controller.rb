class FillerVideosController < ApplicationController
  include FillerTool

  def index
    limit = params[:limit].to_i
    limit = 100 if limit == 0
    render :json => FillerVideo.limit(limit)
  end

  def create
    @video =  FillerVideo.new(filler_video_params)
    begin
      if @video.save
        render json: @video, status: :created
      else
        render json: @video.errors, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique
      render json: {"errors" => "A filler video with the same name and source already exisits"}, status: :unprocessable_entity
    end  
 
  end

  def show
    begin
      render :json => FillerVideo.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: {"error" => "Cannot find a filler video with id #{params[:id]}"}, status: :not_found
    end
  end

  def update
    begin
      @video = FillerVideo.find(params[:id])
      if @video.update(filler_video_params)
        render json: @video, status: :ok
      else
        render json: @video.errors, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique
      render json: {"errors" => "Another filler video with the same name and source exisits"}, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound
      render json: {"error" => "Cannot find the filler video", "id" => params[:id]}, status: :not_found
    end  
  end

  def destroy
    begin
      @video = FillerVideo.find(params[:id])
      @video.destroy
      render json: {"msg" => "Filler video was successfully deleted", "id" => params[:id]}, statuns: :ok
    rescue ActiveRecord::RecordNotUnique
      render json: {"errors" => "Another filler video with the same name and source exisits"}, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound
      render json: {"error" => "Cannot find the filler video", "id" => params[:id]}, status: :not_found
    end
  end

  def find
    duration = params[:duration].to_i
    minCandidate = (params["min_candidate"].nil?) ? 1 : params["min_candidate"].to_i
    maxCandidate = (params["max_candidate"].nil?) ? 10 : params["max_candidate"].to_i
    gapAllowed = (params["allowed_gap"].nil?) ? 3 : params["allowed_gap"].to_i
    duplicate = (params["allow_duplicate"].nil?) ? false : (params["allow_duplicate"].downcase.eql?("true"))

    if duration <= 0
      render json: {"error" => "Invalid parameter 'duration'"}, status: :bad_request
    elsif minCandidate <= 0
      render json: {"error" => "Invalid parameter 'min_candidate'"}, status: :bad_request
    elsif minCandidate > maxCandidate
      render json: {"error" => "Invalid parameter 'max_candidate'"}, status: :bad_request
    elsif gapAllowed < 0
      render json: {"error" => "Invalid parameter 'allowed_gap'"}, status: :bad_request
    else
      render json: FillerTool.findFillers(duration, minCandidate, maxCandidate, gapAllowed, duplicate)
    end
  end

  private

  def filler_video_params
    params.require(:filler_video).permit(:name, :source, :video_url, :length)
  end
end
