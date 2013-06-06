require 'spec_helper'

describe 'shared/_navigation.html.erb' do
  it 'shows a link to create a new notice' do
    render

    expect(page).to contain_link(new_notice_path)
  end

  def contain_link(path, title = nil)
    selector = %{a[href="#{path}"]}

    if title
      selector << ":contains('#{title}')"
    end

    have_css(selector)
  end
end
