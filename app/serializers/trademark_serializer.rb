class TrademarkSerializer < NoticeSerializer
  attributes :marks, :mark_registration_number

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
