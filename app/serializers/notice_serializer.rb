class NoticeSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :date_sent, :notice_file_content
end
