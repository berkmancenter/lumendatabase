RSpec::Matchers.define :have_facets do |facet|
  match do |results|
    result = results.facets &&
       results.facets[facet] &&
        results.facets[facet]['terms'].map { |t| t['term'] }

    return_value = result

    if @check_terms
      return_value = (result.sort == @expected_terms.sort)
    end
    return_value
  end

  chain :with_terms do |values|
    @check_terms = true
    @expected_terms = values
  end
end
