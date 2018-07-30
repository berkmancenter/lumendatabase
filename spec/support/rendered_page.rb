module RenderedPage
  attr_writer :page

  def page
    @page ||= Capybara::Node::Simple.new(rendered)
  end

  def within(selector, &block)
    outer_page = page
    self.page = outer_page.find(selector)

    yield

  ensure
    self.page = outer_page
  end
end

RSpec.configure do |config|
  #config.include RenderedPage, type: :view
end
