module ParamFlattener
  private

  # JSON API submissions:
  #
  #   [{ ... }, { ... }, { ... }]
  #
  # Rails form submissions:
  #
  #   { '0' => { ... }, '1' => { ... }, '3' => { ... } }
  #
  # This flattens the second style to the first, IFF it's not that way
  # already. Curse you, Rails for making me type-check.
  def flatten_param(param)
    case param
    when ActionController::Parameters then param.values
    when Hash  then param.values
    when Array then param
    else []
    end
  end
end
