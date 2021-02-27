class Ability
  include CanCan::Ability

  def initialize(user)
    can :request_access_token, Notice do |notice|
      !notice&.submitter&.full_notice_only_researchers
    end

    can :create_access_token, Notice do |notice|
      !notice&.submitter&.full_notice_only_researchers
    end

    return unless user

    if user.role?(Role.notice_viewer)
      if user.can_generate_permanent_notice_token_urls
        can :generate_permanent_notice_token_urls, Notice do |notice|
          full_notice_only_researchers?(notice, user)
        end
      end

      can_view_full_version = true

      can_view_full_version = false if user.notice_viewer_views_limit && user.notice_viewer_viewed_notices >= user.notice_viewer_views_limit
      can_view_full_version = false if user.notice_viewer_time_limit && Time.now > user.notice_viewer_time_limit

      if can_view_full_version
        can :view_full_version, Notice do |notice|
          full_notice_only_researchers?(notice, user)
        end
      end
    end

    can :submit, Notice if user.role?(Role.submitter)

    if user.role?(Role.redactor)
      grant_admin_access
      grant_redact
    end

    if user.role?(Role.publisher)
      grant_admin_access
      grant_redact

      can :publish, Notice
    end

    if user.role?(Role.admin)
      grant_admin_access
      grant_redact
      grant_full_notice_api_response(user)

      can :update, :all
      cannot :update, [User, Role]

      can :publish, Notice
      can :rescind, Notice
      can :create, Notice

      can :pdf_requests, :all
      can :view_full_version, Notice
      can :generate_permanent_notice_token_urls, Notice
      can %i[index show create update read manage], 'Cms::Site'
    end

    if user.role?(Role.super_admin)
      grant_full_notice_api_response(user)

      can :manage, :all
      can :view_full_version, Notice
    end

    if user.role?(Role.researcher)
      grant_full_notice_api_response(user)

      can :read, Notice
      can :view_full_version, Notice do |notice|
        full_notice_only_researchers?(notice, user)
      end
    end
  end

  def grant_admin_access
    can :read, :all
    can :access, :rails_admin
    can :read, :dashboard
    can :search, Entity
    can :access, :original_files
  end

  # Note that this only covers Notice, because it governs use of the admin
  # interface, and redaction of other models in the admin has not been
  # implemented.
  def grant_redact
    can :update, Notice
    can :redact_notice, Notice
    can :redact_queue, Notice
  end

  def grant_full_notice_api_response(user)
    return if user.limit_notice_api_response

    can :view_full_version_api, Notice do |notice|
      full_notice_only_researchers?(notice, user)
    end
  end

  def full_notice_only_researchers?(notice, user)
    return false if notice&.submitter&.full_notice_only_researchers &&
                    notice&.submitter&.full_notice_only_researchers_users&.any? &&
                    !notice.submitter.full_notice_only_researchers_users.include?(user)

    true
  end
end
