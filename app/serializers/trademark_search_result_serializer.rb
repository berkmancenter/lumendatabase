class TrademarkSearchResultSerializer < TrademarkSerializer
  attributes :score

  self.root = :trademark

  def score
    object._score
  end
end
