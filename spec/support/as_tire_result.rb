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
      'class_name' => notice.class.to_s,
      'highlight' => nil
    }.merge(options)

    JSON.parse(notice.to_indexed_json).merge(metadata)
  end
end

RSpec.configure do |config|
  config.include AsTireResult

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
end
