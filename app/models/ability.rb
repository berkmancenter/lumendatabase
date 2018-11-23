class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    if user.has_role?(Role.notice_viewer)
      grant_permanent_notice_url_generation(user)

      can_view_full_version = true

      can_view_full_version = false if user.notice_viewer_views_limit && user.notice_viewer_viewed_notices >= user.notice_viewer_views_limit
      can_view_full_version = false if user.notice_viewer_time_limit && Date.now > user.notice_viewer_time_limit

      can :view_full_version, Notice if can_view_full_version
    end

    can :submit, Notice if user.has_role?(Role.submitter)

    if user.has_role?(Role.redactor)
      grant_admin_access
      grant_redact
    end

    if user.has_role?(Role.publisher)
      grant_admin_access
      grant_redact

      can :publish, Notice
    end

    if user.has_role?(Role.admin)
      grant_admin_access
      grant_redact
      grant_permanent_notice_url_generation(user)
      grant_full_notice_api_response(user)

      can :edit, :all
      cannot :edit, [User, Role]

      can :publish, Notice
      can :rescind, Notice
      can :create, Notice
      can :create, BlogEntry

      can :pdf_requests, :all
      can :view_full_version, Notice
    end

    if user.has_role?(Role.super_admin)
      grant_permanent_notice_url_generation(user)
      grant_full_notice_api_response(user)

      can :manage, :all
      can :view_full_version, Notice
    end

    if user.has_role?(Role.researcher)
      grant_full_notice_api_response(user)

      can :read, Notice
    end
  end

  def grant_admin_access
    can :read, :all
    can :access, :rails_admin
    can :dashboard
    can :search, Entity
    can :access, :original_files
  end

  # Note that this only covers Notice, because it governs use of the admin
  # interface, and redaction of other models in the admin has not been
  # implemented.
  def grant_redact
    can :edit, Notice
    can :redact_notice, Notice
    can :redact_queue, Notice
  end

  def grant_permanent_notice_url_generation(user)
    return unless user.can_generate_permanent_notice_token_urls

    can :generate_permanent_notice_token_urls, Notice
  end

  def grant_full_notice_api_response(user)
    can :view_full_version_api, Notice unless user.limit_notice_api_response
  end
end
