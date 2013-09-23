require 'spec_helper'
require 'collapses_categories'

describe CollapsesCategories do
  [BlogEntry, CategoryManager, RelevantQuestion, Notice].each do |model|
    it "correctly merges a set of categories together for #{model.name}" do
      factory_name = singular_name = model.name.tableize.singularize
      if singular_name == 'notice'
        factory_name = 'dmca'
      end
      from_cat = create(:category, name: 'Cat to remove')
      to_cat = create(:category, name: 'Cat to merge into')
      other_cat = create(:category)

      2.times do
        create(factory_name, categories: [from_cat, to_cat, other_cat])
      end

      collapser = CollapsesCategories.new(from_cat.name, to_cat.name)
      collapser.collapse

      expect(Category.find_by_name(from_cat.name)).to be_nil
      expect(to_cat.send("#{singular_name}_ids")).to match_array(model.all.map(&:id))
      expect(other_cat.send("#{singular_name}_ids")).to match_array(model.all.map(&:id))
      expect(from_cat.notice_ids).to be_empty
    end
  end
end
