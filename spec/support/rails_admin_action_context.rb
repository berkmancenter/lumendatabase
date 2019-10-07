module RailsAdminActionContext
  attr_reader :request, :format, :params

  attr_accessor :current_user

  def setup_action_context
    @request = double('Request', get?: false, put?: false, post?: false)
    @format = double('Format', html: nil, js: nil)
    @params = ActionController::Parameters.new

    @object = double('Object', id: 1, save: false).as_null_object
    @action = double('Action', template_name: '')
    @abstract_model = double('Abstract model', param_key: nil)
    @model_config = double('Model config', with: nil)
  end

  def respond_to
    yield(format)
  end
end
