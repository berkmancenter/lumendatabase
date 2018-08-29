require_relative '../page_object'
require_relative '../sign_in'

class AdminOnPage < PageObject
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def sign_into_admin
    sign_in @user
    visit_admin
  end

  def visit_admin
    visit '/admin'
  end

  def create(model_class)
    visit "#{model_path(model_class)}/new"
  end

  def delete(resource)
    visit "#{model_path(resource)}/#{resource.id}/delete"
  end

  def edit(resource, edits = {})
    visit "#{model_path(resource)}/#{resource.id}/edit"

    if edits.present?
      edits.each { |k,v| fill_in k, with: v }
      click_on 'Save'
    end
  end

  def redact(notice)
    visit "/admin/notice/#{notice.id}/redact_notice"
  end

  def redirected_to_sign_in?
    current_path == '/users/sign_in'
  end

  def denied_access?
    within('#flash') do
      current_path == '/' && page.has_content?(/you are not authorized/i)
    end
  end

  def in_admin?
    current_path =~ %r{^/admin}
  end

  # These sign-in-and-X methods are a code smell, indicating that PageObject
  # has bundled too many things together (both a user and the actions that a
  # user can take). However, they greatly improve the readability of their
  # associated tests by allowing for reuse of the sign_in function used
  # elsewhere in tests, and this is simpler than refactoring PageObject.
  def sign_in_and_create(model_class)
    sign_in @user
    create(model_class)
  end

  def sign_in_and_edit(resource, edits = {})
    sign_in @user
    edit(resource, edits)
  end

  def sign_in_and_redact(notice)
    sign_in @user
    redact(notice)
  end

  private

  def model_path(model)
    model_class = model.is_a?(Class) ? model : model.class

    "/admin/#{model_class.table_name.singularize}"
  end
end
