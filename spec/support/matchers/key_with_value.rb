RSpec::Matchers.define :have_key do |key|
  match do |json|
    @actual_value = json[key.to_s]

    return_value = json.key?(key.to_s)
    return_value &&= @actual_value == @expected_value if @check_value

    return_value
  end

  chain :with_value do |value|
    @check_value = true
    @expected_value = value
  end

  failure_message_for_should do |actual|
    message  = "expected JSON hash to have key #{key.inspect}"
    message << " with value #{@expected_value.inspect}" if @check_value
    message << ", was #{@actual_value.inspect}"

    message
  end
end
