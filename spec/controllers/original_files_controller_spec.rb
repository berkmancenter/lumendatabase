require 'rails_helper'

describe OriginalFilesController do

  describe "GET 'show'" do
    let(:upload) { create(:file_upload) }
    it "returns not found without valid params" do
      get 'show', id: upload.id, file_path: ['a', 'b', 'c']
      expect(response).not_to be_success
    end

    it "returns http success" do
      allow(File).to receive(:file?).and_return(:true)
      allow(File).to receive(:read).and_return('Content!')
      expect(response).to be_success
    end
  end

end
