class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    if user.has_role?(Role.submitter)
      can :submit, Notice
    end

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

      can :edit, :all
      cannot :edit, [User, Role]

      can :publish, Notice
      can :rescind, Notice
      can :create, Notice
      can :create, BlogEntry

      can :pdf_requests, :all
    end

    if user.has_role?(Role.super_admin)
      can :manage, :all
    end

    if user.has_role?(Role.researcher)
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
end
