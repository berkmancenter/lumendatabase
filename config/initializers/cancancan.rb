# frozen_string_literal: true

require 'lumen/ability'

module CanCan
  module ControllerAdditions
    def current_ability
      @current_ability ||= Lumen::Ability.new(current_user)
    end
  end
end
