require 'spec_helper'

describe SubmissionIdsController do
  context "#show" do
    it "redirects to a notice_id according to its submission_id" do
      notice = build(:dmca, id: 1000)
      Notice.should_receive(:find_by_submission_id).with('2000').and_return(notice)

      get :show, id: 2000

      expect(response).to redirect_to('/notices/1000')
      expect(response.code).to eq "301"
    end

    it "gives a 404 when a mapping isn't found" do
      Notice.should_receive(:find_by_submission_id).and_return(nil)
      get :show, id: 2000

      expect(response).to be_not_found
    end
  end
end
