class ModelHandler
  def initialize(model)
    @model = model
    @name = model.external_name
  end

  def find(id)
    begin
      @item = @model.find id
      return [@item, nil, 200]
    rescue ActiveRecord::RecordNotFound
      return no_item(id)
    end
  end

  def create(params)
    begin
      @item = @model.new @model.external_params(params)
      return [@item, {"error" => @item.errors.full_messages}, 400] if !@item.valid?
      if @item.save
        return [@item, {"info" => "#{@name} #{@item.id} was created"}, 201]
      else
        return [@item, {"error" => @item.errors.full_messages}, 422]
      end
    rescue ActiveRecord::RecordNotUnique
      return duplicate_item
    rescue ActiveRecord::ActiveRecordError => e
      return [params, {"error" => e.message}, 400]
    end
  end

  def update(id, params)
    begin
      @item = @model.find id
      if @item.update(@model.external_params(params))
        return [@item, {"info" => "#{@name} #{@item.id} was updated"}, 200]
      else
        return [@item, {"error" => @item.errors.full_messages}, 400]
      end
    rescue ActiveRecord::RecordNotFound
      return no_item(id)
    rescue ActiveRecord::RecordNotUnique
      return duplicate_item
    rescue ActiveRecord::ActiveRecordError => e
      return [@item, {"error" => e.message}, 400]
    end
  end

  def destroy(id)
    begin
      @item = @model.find id
      @item.destroy
      return [{"info" => "#{@name} #{id} was deleted"}, 200]
    rescue ActiveRecord::RecordNotFound
      return no_item(id)[1, 2]
    end
  end

  def no_item(id)
    [nil, {"error" => "Cannot find #{@name.downcase} #{id}"}, 404]
  end

  def duplicate_item
    [@item, {"error" => "Duplicate #{@name} already exisits"}, 409]
  end
end
