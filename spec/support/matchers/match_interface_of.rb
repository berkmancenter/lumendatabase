RSpec::Matchers.define :match_interface_of do
  match do
    missing_methods.empty?
  end

  failure_message do
    "expected #{actual.name} to respond to #{missing_methods.join(', ')}"
  end

  def missing_methods
    expected_methods - actual_methods - common_methods
  end

  def expected_methods
    expected.map(&:instance_methods).flatten
  end

  def actual_methods
    actual.instance_methods
  end

  def common_methods
    Object.instance_methods
  end
end
