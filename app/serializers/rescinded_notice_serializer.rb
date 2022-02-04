class RescindedNoticeSerializer < BaseSerializer
  set_type :notice
  attributes :id, :title, :body

  attribute :body do
    'Notice Rescinded'
  end
end
