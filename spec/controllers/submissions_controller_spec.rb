require 'spec_helper'

describe SubmissionsController do
  context "#create from JSON" do
    it "creates and saves a submission from request parameters" do
      submission = double("Submission")
      submission.should_receive(:save).and_return(true)
      Submission.should_receive(:new).with('title' => "A Title").and_return(submission)

      post_valid_submission_with_title 'A Title'
    end

    it "returns successfully when a submission is saved" do
      submission = double("Submission", save: true)
      Submission.stub(:new).and_return(submission)

      post_valid_submission_with_title 'A Title'

      expect(response).to be_successful
    end

    it "returns a useful status code when a required parameter is missing" do
      submission = double(save: false, errors: double(full_messages: []))
      Submission.stub(:new).and_return(submission)

      post_invalid_submission

      expect(response).to be_a_bad_request
    end

    it "returns a useful error when a required parameter is missing" do
      post_invalid_submission

      expect(response.body).to include "Title can't be blank"
    end
  end

  context "#create from HTML" do
    it "should redirect when saved successfully" do
      post_valid_submission_with_title("My Notice Title", :html)

      expect(response).to redirect_to(:root)
    end

    it "should render the new template" do
      post_invalid_submission(:html)

      expect(response).to render_template(:new)
    end
  end

  private

  def post_invalid_submission(format = :json)
    post :create, submission: { file: '' }, format: format
  end

  def post_valid_submission_with_title(title, format = :json)
    post :create, submission: { title: title }, format: format
  end
end
