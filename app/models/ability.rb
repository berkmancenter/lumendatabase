class Ability
  include CanCan::Ability

  def initialize(user)
    # anonymous user
    can :request_access_token, Notice do |notice|
      !notice&.submitter&.full_notice_only_researchers
    end

    can :create_access_token, Notice do |notice|
      !notice&.submitter&.full_notice_only_researchers
    end

    return unless user

    # general
    if user.can_generate_permanent_notice_token_urls
      can :generate_permanent_notice_token_urls, Notice do |notice|
        full_notice_only_researchers?(notice, user)
      end
    end

    # notice_viewer role
    if user.role?(Role.notice_viewer)
      can_view_full_version?(user)
    end

    # submitter role
    can :submit, Notice if user.role?(Role.submitter)

    # redactor role
    if user.role?(Role.redactor)
      grant_admin_access
      grant_redact
    end

    # publisher role
    if user.role?(Role.publisher)
      grant_admin_access
      grant_redact

      can :publish, Notice
    end

    # admin role
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

    # super_admin role
    if user.role?(Role.super_admin)
      grant_full_notice_api_response(user)

      can :manage, :all
      can :view_full_version, Notice
    end

    # researcher role
    if user.role?(Role.researcher)
      grant_full_notice_api_response(user)

      can :read, Notice

      can_view_full_version?(user)

      cannot :generate_permanent_notice_token_urls, Notice do |notice|
        full_notice_only_researchers?(notice, user) == false ||
          (notice&.submitter&.full_notice_only_researchers && !user.allow_generate_permanent_tokens_researchers_only_notices)
      end
    end
  end

  private

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

  def can_view_full_version?(user)
    can_view_full_version = true

    can_view_full_version = false if user.full_notice_views_limit && user.viewed_notices >= user.full_notice_views_limit
    can_view_full_version = false if user.full_notice_time_limit && Time.now > user.full_notice_time_limit.in_time_zone(ENV['SERVER_TIME_ZONE'])

    if can_view_full_version
      can :view_full_version, Notice do |notice|
        full_notice_only_researchers?(notice, user)
      end
    end
  end
end
