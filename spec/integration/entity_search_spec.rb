require 'spec_helper'

feature "Searching Entities" do
  include CurbHelpers

  scenario 'entities are found by name', js: true, search: true do
    entity = create(:entity, :with_parent, name: 'Foo bar')

    expect_entity_api_search_to_find('bar') do|json|
      json_item = json['entities'].first

      expect(json_item).to have_key('id').with_value(entity.id.to_s)
      expect(json_item).to have_key('parent_id').with_value(entity.parent_id)
      %w(parent_id name address_line_1 address_line_2 state
         country_code phone email url city).each do |key|
        expect(json_item).to have_key(key).with_value(entity.send(key.to_sym))
      end
    end
  end

  scenario 'the results have relevant metadata', js: true, search: true do
    entity = create(:entity, name: 'Foo bar')

    expect_entity_api_search_to_find('bar') do|json|
      metadata = json['meta']
      expect(metadata).to have_key('current_page').with_value(1)
      expect(metadata).to have_key('query').with_value("term" => "bar")
    end
  end

end

def expect_entity_api_search_to_find(term, options = {})
  sleep 1

  with_curb_get_for_json(
    "entities/search.json",
    options.merge(term: term)) do |curb|
    json = JSON.parse(curb.body_str)
    yield(json) if block_given?
    end
end
