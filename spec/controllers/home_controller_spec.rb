require 'rails_helper'

describe HomeController do
  before(:each) do
    Rails.cache.clear
  end
  context "#index" do
    it "finds recent notices" do
      notices = double("Notices")
      expect(Notice).to receive(:recent).and_return(notices)

      get :index

      expect(response).to be_successful
      expect(assigns(:notices)).to eq notices
    end

    it "finds recent blog entries" do
      blog_entries = double("Blog entries")
      expect(BlogEntry).to receive(:recent_posts).and_return(blog_entries)

      get :index

      expect(response).to be_successful
      expect(assigns(:blog_entries)).to eq blog_entries
    end
  end
end
