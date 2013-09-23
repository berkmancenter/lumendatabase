class CollapsesCategories

  def initialize(from, to)
    @from = Category.find_by_name(from)
    @to = Category.find_by_name(to)
  end

  MODELS = %w|
    BlogEntry
    CategoryManager
    RelevantQuestion
    Notice
  |

  def collapse
    MODELS.map(&:constantize).each do |model|
      to_remove = model.select("#{model.to_s.tableize}.*").joins(:categories).where("category_id = ?", @from.id)
      to_remove.each do |instance|
        instance.categories.delete(@from)
        instance.category_ids << @to.id
        instance.save
      end
    end

    @from.destroy
  end

end
