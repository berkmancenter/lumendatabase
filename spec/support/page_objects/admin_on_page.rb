require_relative '../page_object'

class AdminOnPage < PageObject
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def sign_in
    visit '/users/sign_out' # clear old session
    visit '/users/sign_in'
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_on "Log in"
  end

  def visit_admin
    visit '/admin'
  end

  def sign_into_admin
    sign_in
    visit_admin
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

  private

  def model_path(model)
    model_class = model.is_a?(Class) ? model : model.class

    "/admin/#{model_class.table_name.singularize}"
  end
end
