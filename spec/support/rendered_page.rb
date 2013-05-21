module RenderedPage
  def page
    @page ||= Capybara.string(rendered)
  end

  def within(selector)
    yield page.find(selector)
  end
end

RSpec.configure do |config|
  config.include RenderedPage, type: :view
end
