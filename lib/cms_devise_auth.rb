module CmsDeviseAuth
  def authenticate
    if current_user
      return true if Ability.new(current_user).can?(:manage, "Cms::Site")
      raise CanCan::AccessDenied
    else
      scope = Devise::Mapping.find_scope!(:user)
      session["#{scope}_return_to"] = comfy_admin_cms_path
      redirect_to new_user_session_path
    end
  end
end
