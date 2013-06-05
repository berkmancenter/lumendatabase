require 'spec_helper'

describe 'notices/new.html.erb' do
  it "has a form for notices" do
    assign(:notice, Notice.new)

    render

    expect(rendered).to have_css 'form'
  end
end
