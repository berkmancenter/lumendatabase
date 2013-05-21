require 'spec_helper'

describe 'submissions/new.html.erb' do
  it "has a form for submissions" do
    assign(:submission, Submission.new)

    render

    expect(rendered).to have_css 'form'
  end
end
