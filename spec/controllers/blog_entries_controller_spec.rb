require 'rails_helper'

describe BlogEntriesController do

  context "#index" do
    it "paginates the 'published' scope on BlogEntry" do
      blog_entries = []
      per_double = double('per', per: blog_entries)
      allow(BlogEntry).to receive_message_chain(:published,:with_content,:page).
        with('2').and_return(per_double)
      allow(BlogEntry).to receive_message_chain(:published,:we_are_reading,:limit).and_return([])

      get :index, page: 2

      expect(assigns(:blog_entries)).to eq blog_entries
      expect(response).to be_successful
    end

    it "includes we_are_reading blog entries" do
      allow(BlogEntry).to receive_message_chain(:published,:with_content,:page, :per).and_return([])

      blog_entries = 'blog entries'
      allow(BlogEntry).to receive_message_chain(:published,:we_are_reading,:limit).and_return(blog_entries)

      get :index, page: 2
      expect(assigns(:we_are_reading)).to eq blog_entries
      expect(response).to be_successful
    end
  end

  context "#archive" do
    it "paginates the 'published' scope on BlogEntry" do
      blog_entries = []
      per_double = double('per', per: blog_entries)
      allow(BlogEntry).to receive_message_chain(:archived,:with_content,:page).
        with('2').and_return(per_double)
      allow(BlogEntry).to receive_message_chain(:published,:we_are_reading,:limit).and_return([])

      get :archive, page: 2

      expect(assigns(:blog_entries)).to eq blog_entries
      expect(response).to be_successful
    end

    it "includes we_are_reading blog entries" do
      allow(BlogEntry).to receive_message_chain(:published,:with_content,:page, :per).and_return([])

      blog_entries = 'blog entries'
      allow(BlogEntry).to receive_message_chain(:published,:we_are_reading,:limit).and_return(blog_entries)

      get :index, page: 2
      expect(assigns(:we_are_reading)).to eq blog_entries
      expect(response).to be_successful
    end
  end

  context "#show" do
    it "loads a blog entry by ID" do
      blog_entry = double("Blog entry")
      expect(BlogEntry).to receive(:find).with('42').and_return(blog_entry)

      get :show, id: 42

      expect(assigns(:blog_entry)).to eq blog_entry
      expect(response).to be_successful
    end
  end


end
