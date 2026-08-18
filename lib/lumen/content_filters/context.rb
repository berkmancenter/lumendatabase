class Lumen::ContentFilters::Context
  def initialize(filters: nil)
    @filters = filters
    @match_sets = {}.compare_by_identity
  end

  def for(notice)
    @match_sets[notice] ||= Lumen::ContentFilters::MatchSet.new(notice, filters)
  end

  private

  def filters
    @filters ||= ContentFilter.all.to_a.freeze
  end
end
