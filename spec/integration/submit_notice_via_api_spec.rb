require 'spec_helper'

feature "notice submission" do

  before do
    FakeWeb.allow_net_connect = true
  end

  scenario "submitting an incomplete notice", js: true do
    with_curb_post_for('{"notice": {"title": "foo" } }') do |curb_response|
      expect(curb_response.response_code).to eq 422
    end
  end

  scenario "submitting a notice", js: true do
    notice_hash = default_notice_hash(title: 'A superduper title')

    with_curb_post_for(request_hash(notice_hash).to_json) do |curb_response|
      expect(curb_response.response_code).to eq 201
      expect(Notice.last.title).to eq 'A superduper title'
    end
  end

  scenario "submitting a notice with an existing Entity", js: true do
    entity = create(:entity)

    notice_hash = default_notice_hash(
      title: 'A notice with an entity created by id',
      entity_notice_roles_attributes: [
        {
          name: 'recipient',
          entity_id: entity.id
        }
      ]
    )

    with_curb_post_for(request_hash(notice_hash).to_json) do |curb_response|
      expect(curb_response.response_code).to eq 201
      expect(Notice.last.recipient).to eq entity
      expect(Notice.last.title).to eq 'A notice with an entity created by id'
    end
  end
end

def with_curb_post_for(json)
  host = Capybara.current_session.server.host
  port = Capybara.current_session.server.port
  curb = Curl.post("http://#{host}:#{port}/notices", json) do |curl|
    curl.headers['Accept'] = 'application/json'
    curl.headers['Content-Type'] = 'application/json'
  end
  yield curb
end

def default_notice_hash(opts = {})
  {
    title: 'A sweet title',
    works_attributes:
    [
      {
        url: 'http://example.com',
        description: 'A work'
      }
    ],
    entity_notice_roles_attributes:
    [
      {
        name: 'recipient',
        entity_attributes: {
          name: 'The Googs'
        }
      }
    ]
  }.merge!(opts)
end

def request_hash(notice_hash)
  {
    notice: notice_hash
  }
end
