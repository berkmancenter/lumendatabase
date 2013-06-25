class NoticeSearchResultSerializer < NoticeSerializer
  attributes :score

  def score
    object._score
  end
end
