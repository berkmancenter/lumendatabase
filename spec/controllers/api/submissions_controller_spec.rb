require 'spec_helper'

module Api
  describe SubmissionsController do
    context "#create" do
      it "calls Submission.create! with request parameters" do
        Submission.should_receive(:create!).with('title' => "A Title")

        post_valid_submission_with_title 'A Title'
      end

      it "returns successfully when a submission is saved" do
        Submission.stub(:create!)

        post_valid_submission_with_title 'A Title'

        expect(response).to be_successful
      end

      it "returns a useful status code when a required parameter is missing" do
        fake_model = double(errors: double(full_messages: []))
        Submission.stub(:create!).and_raise(
          ActiveRecord::RecordInvalid.new(fake_model)
        )

        post_invalid_submission

        expect(response).to be_a_bad_request
      end

      it "returns a useful error when a required parameter is missing" do
        post_invalid_submission

        expect(response.body).to include "Title can't be blank"
      end

      private

      def post_invalid_submission
        post :create, submission: { file: '' }
      end

      def post_valid_submission_with_title(title)
        post :create, submission: { title: title }
      end

    end
  end
end
