class TrademarkSearchResultSerializer < TrademarkSerializer
  attributes :score

  def score
    object._score
  end
end
