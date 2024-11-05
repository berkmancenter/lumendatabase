require 'rails_helper'

describe 'rake lumen:import_github_notices', type: :task, vcr: true do
  before :all do
    create(:court_order, :with_document)
    user = create(:user, :submitter, email: LumenSetting.get('github_user_email'))
    create(:entity, name: 'GitHub', users: [user])

    LumenSetting.where(key: 'github_api_token').first.update(value: 'test')

    ENV['GH_IMPORT_DATE_FROM'] = '2024-07-19T00:00:00Z'
  end

  it 'ingests github notices' do
    # See /spec/vcr/rake_lumen_import_github_notices for the cassette

    initial_count = Notice.count

    task.execute

    notices = Notice.last(3)
    expect(notices[0].principal.name).to eq('Nebula')
    expect(notices[1].principal.name).to eq('Poki')
    expect(notices[2].principal.name).to eq('Metaquotes')

    expect(notices[0].recipient.name).to eq('GitHub')
    expect(notices[1].recipient.name).to eq('GitHub')
    expect(notices[2].recipient.name).to eq('GitHub')

    expect(notices[0].works.first.infringing_urls.length).to eq(3)
    expect(notices[1].works.first.infringing_urls.length).to eq(1)
    expect(notices[2].works.first.infringing_urls.length).to eq(123)

    expect(notices[0].works.first.description).to include("Nebula, the software redistributed in the GitHub repositories in question, is a theme for")
    expect(notices[1].works.first.description).to include("The game Stickman Hook is an HTML5 web game and is exclusively licensed to Poki BV to")
    expect(notices[2].works.first.description).to include("MetaQuotes is the developer of the MetaTrader")

    final_count = Notice.count
    expect(final_count - initial_count).to eq(3)
  end
end
