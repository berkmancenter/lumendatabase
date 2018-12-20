RSpec::Matchers.define :have_heading do |heading|
  match do |page|
    @page = page
    @page.has_css?("h2:contains('#{heading}')")
  end

  failure_message do |_|
    message = "expected page to have heading #{heading}"

    message << if (element = @page.first('h2', minimum: 0)).present?
                 ", actual heading was #{element.text}."
               else
                 ', no element found.'
               end

    message
  end
end
