require 'rails_helper'

describe OriginalNoticeIdsController do
  it_behaves_like "a redirecting controller for",
    Notice, :dmca, :find_by_original_notice_id
end
