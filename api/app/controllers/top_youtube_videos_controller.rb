require 'model_handler'
require 'time'

class TopYoutubeVideosController < ApiController
  def initialize
    super(TopYoutubeVideo)
    @task_prefix = "top_video"
  end

  def import
    data = params
    begin
      msg, code = @model._import(params[:category], params[:youtube_ids])
    rescue ActiveRecord::ActiveRecordError => e
      msg, code = {"error" => e.message}, 400
    end
    json_rsp(data, msg, code, 200)
  end

  def activate
    data, msg, code = params, nil, nil
    begin
      data, msg, code = _find_top_videos(params[:category], TopYoutubeVideo.import_tag)
      if data.nil?
        msg, code = {"error" => "Top videos has not been imported, please import them first"}, 404
      else
        params[:tag] = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
        params[:youtube_ids] = data
        data, msg, code = ModelHandler.new(TopYoutubeVideo).create(params)
        if code == 201
          data, msg, code = ActiveLabel._update(_task(params[:category]), params[:tag])
        end
      end
    rescue ActiveRecord::ActiveRecordError => e
      msg, code = {"error" => e.message}, 400
    end
    json_rsp(data, msg, code, 200)
  end

  def imported
    data, msg, code = params, nil, nil
    begin
      data, msg, code = _find_top_videos(params[:category], TopYoutubeVideo.import_tag)
      msg, code = {"error" => "Top videos has not been imported, please import them first"}, 404 if data.nil?
    rescue ActiveRecord::ActiveRecordError => e
      msg, code = {"error" => e.message}, 400
    end
    json_rsp(data, msg, code, 200)
  end

  def active
    data, msg, code = ActiveLabel._find(_task(params[:category]))
    if data.nil?
      msg, code = {"error" => "Top videos have not been activated"}, 404
    else
      data, msg, code = _find_top_videos(params[:category], data.label)
    end
    json_rsp(data,msg, code, 200)
  end

  def _task(category)
    (category.nil?) ? @task_prefix : @task_prefix + "_" + category
  end

  def _update_active_label(task, label)
    begin
      ActiveLabel.find_or_create_by(task: task).update_attributes({"label": label})
      return [{"task": task, "label": label}, {"info" => "Active label of #{task} is set to #{label}"}, 200]
    rescue ActiveRecord::ActiveRecordError => e
      return [{}, {"error" => e.message}, 400]
    end
  end

  def _find_active_label(task)
    begin
      records = self.where(task: task).limit(1)
      data = (records.size > 0) ? records[0] : nil
      return [data, nil, 200]
    rescue ActiveRecord::ActiveRecordError => e
      return [nil, {"error" => e.message}, 400]
    end
  end

  def _find_top_videos(category, tag)
    data = {"category": category, "tag": tag}
    begin
      records = @model._find(category, tag)
      return [data, {"error" => "Invalid category"}, 400] if records.nil?
      return [nil, {"error" => "Cannot find top videos"}, 404] if records.size == 0

      data = JSON.parse(records[0].youtube_ids)
      return [data, nil, 200]
    rescue ActiveRecord::ActiveRecordError => e
      return [data, {"error" => e.message}, 400]
    end
  end
end
