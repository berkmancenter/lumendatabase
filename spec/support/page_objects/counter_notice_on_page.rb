require_relative '../page_object'

class CounterNoticeOnPage < PageObject

  def choose_radio_option(option)
    choose(option)
  end

  def visit_counter_notice_page
    visit '/counter_notices/new'
  end

  def fill_in_user_form_with(attributes)
    within('section.about-you') do
      attributes.each do |key, value|
        fill_in key, with: value
      end
    end
  end

  def fill_in_service_provider_form_with(attributes)
    within('section.about-your-service-provider') do
      attributes.each do |key, value|
        fill_in key, with: value
      end
    end
  end

  def submit
    click_on 'Create Counter Notification'
  end

end
