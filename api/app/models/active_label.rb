class ActiveLabel < ActiveRecord::Base
  validates :task, :label, presence: true
  self.primary_key = 'task'

  def self.external_name
    return "Active Label"
  end

  def self.external_params(params)
    params.permit(:task, :label)
  end

  def self._update(task, label)
    begin
      self.find_or_create_by(task: task).update_attributes({label: label})
      return [{"task": task, "label": label}, {"info" => "Active label of #{task} is set to #{label}"}, 200]
    rescue ActiveRecord::ActiveRecordError => e
      return [{}, {"error" => e.message}, 400]
    end
  end

  def self._find(task)
    begin
      records = self.where("task": task).limit(1)
      data = (records.size > 0) ? records[0] : nil
      return [data, nil, 200]
    rescue ActiveRecord::ActiveRecordError => e
      return [nil, {"error" => e.message}, 400]
    end
  end
end
