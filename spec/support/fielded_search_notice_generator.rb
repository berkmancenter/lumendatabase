class FieldedSearchNoticeGenerator
  include FactoryGirl::Syntax::Methods

  def initialize(field)
    @field = field
  end

  def self.generate(field)
    instance = new(field)
    instance.send("for_#{field.parameter}".to_sym).tap do
      sleep 1
    end
  end

  def for_title
    in_field = create(
      :dmca, :with_facet_data, @field.field => "Notice with #{@field.title}"
    )
    outside_field = create(
      :dmca, :with_facet_data, title: "N/A", tag_list: [ @field.title ]
    )
    return in_field, outside_field
  end

  def for_sender_name
    role_of_concern = @field.parameter.to_s.gsub(/_name/,'')

    matching_entity = build(:entity, name: @field.title)
    non_matching_entity = build(:entity, name: 'Joe Schmoe')

    in_field = build(
      :dmca, entity_notice_roles: [
        build(:entity_notice_role, name: role_of_concern, entity: matching_entity),
      ]
    )
    in_field.save!

    outside_field = build(
      :dmca, title: "I am not found",
      entity_notice_roles: [
        build(:entity_notice_role, name: role_of_concern, entity: non_matching_entity)
      ]
    )
    outside_field.save!

    return in_field, outside_field
  end

  alias :for_recipient_name :for_sender_name

  def for_tags
    in_field = build(
      :dmca, :with_facet_data, @field.field => [ @field.title ]
    )
    in_field.save!

    outside_field = create(
      :dmca, :with_facet_data, title: "I am not found"
    )
    return in_field, outside_field
  end

  alias :for_jurisdictions :for_tags

  def for_categories
    matching_category = build(:category, name: 'Categories name that matches')
    non_matching_category = build(:category, name: 'Non matching')

    in_field = build(
      :dmca, :with_facet_data, categories: [ matching_category ]
    )
    in_field.save!

    outside_field = build(
      :dmca, :with_facet_data, title: 'I am not found', 
      categories: [ non_matching_category ]
    )
    outside_field.save!
    return in_field, outside_field
  end

  def for_works
    matching_work = build(:work, description: 'Works Description that matches')
    non_matching_work = build(:work, description: 'Non matching')

    in_field = build(
      :dmca, :with_facet_data, works: [ matching_work ]
    )
    in_field.save!

    outside_field = build(
      :dmca, :with_facet_data, title: 'I am not found', 
      works: [ non_matching_work ]
    )
    outside_field.save!

    return in_field, outside_field
  end

end
