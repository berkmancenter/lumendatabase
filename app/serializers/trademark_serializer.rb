class TrademarkSerializer < NoticeSerializer
  attribute :marks

  def marks
    object.works.map(&:description)
  end

  private

  def attributes
    hsh = super
    hsh.delete(:works)

    hsh
  end

end
