module ContainLink
  def contain_link(path, title = nil)
    selector = "a[href='#{path}']"

    if title
      selector << ":contains('#{title}')"
    end

    have_css(selector)
  end
end

RSpec.configure do |config|
  config.include ContainLink, type: :view
  config.include ContainLink, type: :feature
end
