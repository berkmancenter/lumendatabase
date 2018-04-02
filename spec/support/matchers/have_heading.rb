RSpec::Matchers.define :have_heading do |heading|
  match do |page|
    @page = page
    @page.has_css?("h2:contains('#{heading}')")
  end

  failure_message do |_|
    message = "expected page to have heading #{heading}"

    if element = @page.first('h2')
      message << ", actual heading was #{element.text}."
    else
      message << ", no element found."
    end

    message
  end
end
