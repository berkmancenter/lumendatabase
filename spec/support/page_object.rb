class PageObject
  include Capybara::DSL

  def fill_in_form_with(attributes)
    within_form do
      attributes.each do |key, value|
        fill_in key, with: value
      end
    end
  end
end
