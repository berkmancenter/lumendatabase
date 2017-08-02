require 'rails_helper'

feature "A client submits invalid json" do
  include CurbHelpers
  context "and they want a JSON response" do
    scenario "they should get a useful error message", js: true do
      curb = post_broken_json_to_api_as('/notices', 'application/json', broken_json)

      expect(curb.response_code).to eq 400
      expect(curb.content_type).to match(/application\/json/)
      expect(curb.body_str).to match("There was a problem in the JSON you submitted:")
    end
  end

  context "and they want an HTML response" do
    scenario "they should get the rails default", js: true do
      pending "Unsure how to trap the error in the server thread"

      curb = post_broken_json_to_api_as('/notices', 'text/html', broken_json)
      expect(curb.response_code).to eq 500
      expect(curb.content_type).to match(/text\/html/)
    end
  end

  def broken_json
    invalid_tokens = ', , '
    broken_json = %Q|{"notice":{"title":"A sweet title",#{invalid_tokens}"works_attributes":[{"description":"A work"}],"entity_notice_roles_attributes":[{"name":"recipient","entity_attributes":{"name":"The Googs"}}]},"authentication_token":"nothinginteresting"}|
  end
end
