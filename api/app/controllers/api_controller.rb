require 'model_handler'

class ApiController < ApplicationController
  def initialize(model)
    @model = model
    super()
  end

  def index
    limit = params[:limit].to_i
    limit = 100 if limit == 0
    render :json => @model.order(id: :desc).limit(limit)
  end

  def create
    data, msg, code = ModelHandler.new(@model).create(params)
    json_rsp(data, msg, code, 201)
  end

  def show
    data, msg, code = ModelHandler.new(@model).find(params[:id])
    json_rsp(data, msg, code, 200)
  end

  def update
    data, msg, code = ModelHandler.new(@model).update(params[:id], params)
    json_rsp(data, msg, code, 200)
  end

  def destroy
    msg, code = ModelHandler.new(@model).destroy(params[:id])
    render json: {"msg" => msg}, status: code
  end
end
