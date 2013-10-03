module ApplicationHelper
  def available_topics
    Topic.ordered
  end

  def topic_roots
    Topic.ordered.roots
  end

  def title(page_header, page_description = nil)
    full_title = [
      page_description,
      page_header,
      'Chilling Effects'
    ].compact.join(' :: ')

    content_for(:title) { full_title }
    content_for(:header) { page_header }
  end

  def admin_show_path(object)
    model_name = RailsAdmin::AbstractModel.new(object.class).to_param

    rails_admin.show_path(model_name: model_name, id: object.id)
  end

  def active_advanced_search_parameters?
    Notice::SEARCHABLE_FIELDS.find { |field| params[field.parameter] }.present?
  end
end
