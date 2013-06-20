module SearchHelper
  def each_highlight(result, &block)
    if highlighted_item = result.highlight
      Notice::HIGHLIGHTS.each do |highlighted_field|
        (highlighted_item.send(highlighted_field) || []).each(&block)
      end
    end
  end

  def formatted_facet_range_time(time)
    Time.at(time / 1000).to_datetime.to_s(:simple)
  end
end
