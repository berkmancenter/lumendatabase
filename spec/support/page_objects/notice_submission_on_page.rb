require_relative '../page_object'

class NoticeSubmissionOnPage < PageObject

  def initialize(notice_class)
    @notice_class = notice_class
  end

  def open_submission_form
    visit '/'

    click_on 'Report a Demand'
    click_on @notice_class.to_s.titleize
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
