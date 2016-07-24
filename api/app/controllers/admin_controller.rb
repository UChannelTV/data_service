require 'model_handler'

class AdminController < ApplicationController
  def initialize(model, modelSerializer = nil)
    @model = model
    @modelSerializer = modelSerializer
    super()
  end

  def index(column = :id, order = :desc)
    flash[:notice] = nil
    @limit = params[:limit].to_i
    @limit = 100 if @limit <= 0
    @records = @model.order(column => order).limit(@limit).collect {|x| convert(x)}
  end

  def new
    flash[:notice] = nil
    @record, @url, @method = convert(@model.new), url_for(action: 'create'), :POST
  end

  def create
    record, msg, code = ModelHandler.new(@model).create(params)

    flash[:notice] = (msg.nil?) ? nil : msg.to_json
    if code == 201
      @record = convert(record)
      render 'show'
    else
      @record = params.as_json
      @url = url_for(action: 'create')
      render 'new'
    end
  end

  def show
    record, msg, code = ModelHandler.new(@model).find(params[:id])
    @record = convert(record)
    flash[:notice] = (msg.nil?) ? nil : msg.to_json
  end

  def edit
    @url, @method = url_for(action: 'update', id: params[:id]), :PUT
    record, msg, code = ModelHandler.new(@model).find(params[:id])
    @record = convert(record)
    flash[:notice] = (msg.nil?) ? nil : msg.to_json
  end

  def update
    record, msg, code = ModelHandler.new(@model).update(params[:id], params)
    @record = convert(record)
    flash[:notice] = (msg.nil?) ? nil : msg.to_json

    if code == 200
      render 'show'
    else
      @url = url_for(action: 'update', id: params[:id])
      render 'edit'
    end
  end

  def destroy
    msg, code = ModelHandler.new(@model).destroy(params[:id])
    flash[:notice] = (msg.nil?) ? nil : msg.to_json
    redirect_to action: 'index'
  end

  def convert(record)
    return nil if record.nil?
    (@modelSerializer.nil?) ? record.as_json : @modelSerializer.new(record).as_json
  end
end
