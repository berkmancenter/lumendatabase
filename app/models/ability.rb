class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

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

      can :edit, :all
      cannot :edit, [User, Role]

      can :publish, Notice
      can :rescind, Notice
      can :create, Notice
      can :create, BlogEntry

      can :pdf_requests, :all
    end

    can :manage, :all if user.has_role?(Role.super_admin)

    can :read, Notice if user.has_role?(Role.researcher)
  end

  def grant_admin_access
    can :read, :all
    can :access, :rails_admin
    can :dashboard
    can :search, Entity
    can :access, :original_files
  end

  def grant_redact
    can :edit, Notice
    can :redact_notice, Notice
    can :redact_queue, Notice
  end
end
