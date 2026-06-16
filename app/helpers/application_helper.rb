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
      'Lumen'
    ].compact.join(' :: ')

    content_for(:title) { full_title }
    content_for(:header) { page_header }
  end

  def admin_show_path(object)
    model_name = RailsAdmin::AbstractModel.new(object.class).to_param

    rails_admin.show_path(model_name: model_name, id: object.id)
  end

  def admin_edit_path(object)
    model_name = RailsAdmin::AbstractModel.new(object.class).to_param

    rails_admin.edit_path(model_name: model_name, id: object.id)
  end

  def can_see_full_notice_version?(notice)
    # Cancancan abilities
    return true if can?(:view_full_version, notice)

    # Safelisted notices
    safelisted_notices = (ENV['SAFELISTED_NOTICES_FULL'] || []).split(',')
    return true if safelisted_notices.include?(notice.id.to_s)

    return false if notice&.restricted_to_lumen_team?

    # Token validation
    TokenUrl.valid?(params[:access_token], notice)
  end

  def can_see_enterprise_notice_version?(notice)
    current_user.present? && can?(:view_enterprise_version, notice)
  end

  def enterprise_area?
    controller_path.to_s.start_with?('enterprise/') &&
      controller_path != 'enterprise/registrations'
  end

  def enterprise_pro_price
    amount = LumenSetting.get('enterprise_pro_price_usd', cache: false)
    return if amount.blank?

    precision = amount.to_f == amount.to_f.round ? 0 : 2
    number_to_currency(amount, precision: precision)
  end

  def application_header_classes
    ['app', ('search-header' if enterprise_settings?)].compact.join(' ')
  end

  def enterprise_navigation?
    enterprise_area? || enterprise_notice_view?
  end

  def enterprise_settings?
    controller_path == 'enterprise/settings'
  end

  def enterprise_notice_view?
    controller_path == 'notices' &&
      action_name == 'show' &&
      current_user&.active_enterprise_account.present?
  end

  def footer_links
    ids = Comfy::Cms::Fragment.where(identifier: 'link_in_footer', boolean: true)
                              .pluck(:record_id)
    Comfy::Cms::Page.where(id: ids)
  end

  def header_links
    ids = Comfy::Cms::Fragment.where(identifier: 'link_in_header', boolean: true)
                              .pluck(:record_id)
    Comfy::Cms::Page.where(id: ids)
  end
end
