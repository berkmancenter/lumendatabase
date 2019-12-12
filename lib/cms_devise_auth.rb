module CmsDeviseAuth
  def authenticate
    if current_user
      return true if Ability.new(current_user).can?(:manage, "Cms::Site")
      raise CanCan::AccessDenied
    else
      scope = Devise::Mapping.find_scope!(:user)
      session["#{scope}_return_to"] = new_cms_admin_site_path
      redirect_to admin_sign_in_path
    end
  end
end
