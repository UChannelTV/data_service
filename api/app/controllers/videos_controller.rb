class VideosController < ApplicationController
  before_action :set_uchannel_video, only: [:show, :edit, :update, :destroy]

  # GET /uchannel_videos
  # GET /uchannel_videos.json
  def index
    @uchannel_videos = Video.all
  end

  # GET /uchannel_videos/1
  # GET /uchannel_videos/1.json
  def show
  end

  # GET /uchannel_videos/new
  def new
    @uchannel_video = Video.new
  end

  # GET /uchannel_videos/1/edit
  def edit
  end

  # POST /uchannel_videos
  # POST /uchannel_videos.json
  def create
    @uchannel_video = Video.new(uchannel_video_params)

    respond_to do |format|
      if @uchannel_video.save
        format.html { redirect_to @uchannel_video, notice: 'Uchannel video was successfully created.' }
        format.json { render :show, status: :created, location: @uchannel_video }
      else
        format.html { render :new }
        format.json { render json: @uchannel_video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /uchannel_videos/1
  # PATCH/PUT /uchannel_videos/1.json
  def update
    respond_to do |format|
      if @uchannel_video.update(uchannel_video_params)
        format.html { redirect_to @uchannel_video, notice: 'Uchannel video was successfully updated.' }
        format.json { render :show, status: :ok, location: @uchannel_video }
      else
        format.html { render :edit }
        format.json { render json: @uchannel_video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uchannel_videos/1
  # DELETE /uchannel_videos/1.json
  def destroy
    @uchannel_video.destroy
    respond_to do |format|
      format.html { redirect_to uchannel_videos_url, notice: 'Uchannel video was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_uchannel_video
      @uchannel_video = Video.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def uchannel_video_params
      params.require(:uchannel_video).permit(:duration, :created_at, :title, :description, :video_url, :tags, :category, :status)
    end
end
