module PredicateHelpers
  # Allows for
  #
  #   expect(subject).to handle(argument)
  #
  # which then calls subject.handles?(argument)
  #
  def handle(argument)
    be_handles(argument)
  end
end

RSpec.configure do |config|
  config.include(PredicateHelpers)
end
