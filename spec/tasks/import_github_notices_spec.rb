require 'rails_helper'

describe 'rake lumen:import_github_notices', type: :task, vcr: true do
  before :all do
    create(:court_order, :with_document)
    ENV['GH_IMPORT_DATE_FROM'] = '2024-07-19T00:00:00Z'
  end

  it 'ingests github notices' do
    # See /spec/vcr/rake_lumen_import_github_notices for the cassette
    expect_to_create_x_notices(2)

    notices = Notice.last(2)
    expect(notices[0].principal.name).to eq('Codility')
    expect(notices[1].principal.name).to eq('Ketchep')
    expect(notices[0].recipient.name).to eq('Github')
    expect(notices[1].recipient.name).to eq('Github')
  end

  private

  def expect_to_create_x_notices(number)
    expect{ task.execute }.to change { Notice.count }.by(number)
  end
end
