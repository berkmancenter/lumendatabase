class TrademarkSerializer < NoticeSerializer
  attribute :marks

  def as_json(*)
    super.tap do |json|
      json[:trademark].delete(:works)
    end
  end

  def marks
    object.works.map(&:description)
  end

end
