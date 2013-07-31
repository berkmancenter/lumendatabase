class TrademarkSerializer < NoticeSerializer
  attribute :marks

  def as_json(*)
    super.except(:works)
  end

  def marks
    object.works.map(&:description)
  end

end
