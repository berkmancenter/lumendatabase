require 'spec_helper'

describe SubmissionsController do
  context "#create from JSON" do
    it "creates and saves a submission from request parameters" do
      title = "A title"
      submission = submission_double
      submission.should_receive(:save).and_return(true)
      Submission.should_receive(:new).with('title' => title).and_return(submission)

      post :create, submission: { title: title }
    end

    it "returns successfully when a submission is saved" do
      post_valid_submission

      expect(response).to be_successful
    end

    it "returns a useful status code when a required parameter is missing" do
      post_invalid_submission

      expect(response).to be_a_bad_request
    end

    it "returns a useful error when a required parameter is missing" do
      post_invalid_submission do |submission|
        submission.stub(:errors).and_return(
          double(full_messages: ["Title can't be blank"])
        )
      end

      expect(response.body).to include "Title can't be blank"
    end

    it "does not normalize parameters" do
      NormalizesParameters.should_not_receive(:normalize)
      post_valid_submission
    end
  end

  context "#create from HTML" do
    it "redirects when saved successfully" do
      post_valid_submission(format: :html)

      expect(response).to redirect_to(:root)
    end

    it "renders the new template" do
      post_invalid_submission(format: :html)

      expect(response).to render_template(:new)
    end

    it "normalizes HTML form parameters" do
      NormalizesParameters.should_receive(:normalize)
      post_valid_submission(format: :html)
    end
  end

  private

  def post_valid_submission(options = {})
    submission = submission_double

    yield(submission) if block_given?

    post_submission(submission, options)
  end

  def post_invalid_submission(options = {})
    submission = submission_double
    submission.stub(:save).and_return(false)
    submission.stub(:errors).and_return(double(full_messages: []))

    yield(submission) if block_given?

    post_submission(submission, options)
  end

  def post_submission(submission, options = {})
    format = options.fetch(:format) { :json }

    Submission.stub(:new).and_return(submission)

    post :create, submission: { title: "A title" }, format: format
  end

  def submission_double
    double("Submission", save: true)
  end

end
