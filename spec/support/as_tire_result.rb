module AsTireResult
  def as_tire_result(notice, options = {})
    wrapper = Tire::Configuration.wrapper
    wrapper.new(with_metadata(notice, options))
  end

  def with_metadata(notice, options = {})
    metadata = {
      '_type' => "notice",
      '_score' => 0.5,
      '_index' => "development__notices",
      '_version' => nil,
      '_explanation' => nil,
      'sort' => nil,
      'highlight' => nil
    }.merge(options)

    JSON.parse(notice.to_indexed_json).merge(metadata)
  end
end

RSpec.configure do |config|
  config.include AsTireResult
end
