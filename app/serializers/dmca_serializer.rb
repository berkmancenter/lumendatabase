class DMCASerializer < NoticeSerializer
  attributes :regulations

  attribute :regulations do |object|
    object.regulation_list
  end
end
