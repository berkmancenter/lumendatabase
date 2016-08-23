RSpec::Matchers.define :have_key do |key|
  match do |json|
    @actual_value = json[key].is_a?(Array) ? json[key].sort : json[key]

    return_value = json.key?(key)
    return_value &&= @actual_value == @expected_value if @check_value

    return_value
  end

  chain :with_value do |value|
    @check_value = true
    # Sort will bork hashes, so no respond_to?
    @expected_value = value.is_a?(Array) ? value.sort : value
  end

  failure_message do |actual|
    message  = "expected JSON hash to have key #{key.inspect}"
    message << " with value #{@expected_value.inspect}" if @check_value
    message << ", was #{@actual_value.inspect}"

    message
  end
end
