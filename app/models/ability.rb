class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    can :read, :all
    can :access, :rails_admin
    can :dashboard

    if user.has_role?(Role.redactor)
      can :edit, Notice
      can :redact_notice, Notice
      can :redact_queue, Notice
    end

    if user.has_role?(Role.publisher)
      can :edit, Notice
      can :redact_notice, Notice
      can :redact_queue, Notice
      can :publish, Notice
    end

    if user.has_role?(Role.admin)
      can :edit, :all
      cannot :edit, [User, Role]

      can :redact_notice, Notice
      can :redact_queue, Notice
      can :publish, Notice
    end

    if user.has_role?(Role.super_admin)
      can :manage, :all
    end
  end
end
