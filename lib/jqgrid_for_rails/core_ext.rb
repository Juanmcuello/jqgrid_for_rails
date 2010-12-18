String.class_eval do
  def to_json_var
    ActiveSupport::JSON::Variable.new(self)
  end
end 
