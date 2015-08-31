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
    end

    if user.has_role?(Role.super_admin)
      can :manage, :all
    end
  end

  def grant_admin_access
    can :read, :all
    can :access, :rails_admin
    can :dashboard
    can :search, Entity
  end

  def grant_redact
    can :edit, Notice
    can :redact_notice, Notice
    can :redact_queue, Notice
  end
end
