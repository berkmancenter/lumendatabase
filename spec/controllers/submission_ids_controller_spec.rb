require 'rails_helper'

describe SubmissionIdsController do
  it_behaves_like "a redirecting controller for",
    Notice, :dmca, :find_by_submission_id
end
