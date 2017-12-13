require_relative '../page_object'

class NoticeSubmissionOnPage < PageObject

  def initialize(notice_class, user = nil)
    @notice_class = notice_class
    @user = user
  end

  def sign_in
    visit '/users/sign_out' # clear old session
    visit '/users/sign_in'
    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password
    click_on "Log in"
  end

  def open_submission_form
    sign_in unless @user.nil?
    
    visit '/notices/new'

    click_on 'Report ' + @notice_class.to_s.titleize
  end

  def within_form(&block)
    within('form.new_notice', &block)
  end

  def choose(value, field)
    select(value, from: "notice_#{field}".to_sym)
  end

  def fill_in_entity_form_with(role, attributes)
    within("section.#{role}") do
      attributes.each do |key, value|
        fill_in key, with: value
      end
    end
  end

  def submit
    click_on 'Submit'
  end

  def within_entity_with_role(role)
    within("section.#{role}") do
      yield
    end
  end

end
