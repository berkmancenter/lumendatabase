require 'spec_helper'

describe CategoriesController do
  context "#show" do
    it "loads the category by ID" do
      category = double("Category").as_null_object
      Category.should_receive(:find).with('42').and_return(category)

      get :show, id: 42

      expect(assigns(:category)).to eq category
      expect(response).to be_successful
      expect(response).to render_template(:show)
    end

    it "uses SearchesModels to find recent notices" do
      category = double("Category")
      category.stub(:name).and_return('A category name')
      Category.stub(:find).and_return(category)

      searcher = SearchesModels.new
      SearchesModels.should_receive(:new).with(
        { category: category.name }).and_return(searcher)

      get :show, id: 42
    end
  end

  context "#index as html" do
    it "cannot be routed" do
      expect do
        get(:index, format: :html)
      end.to raise_error(ActionController::RoutingError)
    end
  end

  context "#index as json" do
    it "loads all categories" do
      category_list = build_list(:category, 10)
      Category.should_receive(:all)

      get :index, format: :json

      expect(response).to be_successful
    end

    it "serializes category data correctly" do
      parent_category = create(:category, name: 'Category 1')
      child_category = create(
        :category, name: "Category 1 child", parent: parent_category
      )

      get :index, format: :json

      json = JSON.parse(response.body)["categories"]
      expect(json.first).to have_key('id').with_value(parent_category.id)
      expect(json.first).to have_key('name').with_value(parent_category.name)
      expect(json.first).to have_key('parent_id').with_value(nil)

      expect(json.last).to have_key('id').with_value(child_category.id)
      expect(json.last).to have_key('name').with_value(child_category.name)
      expect(json.last).to have_key('parent_id').with_value(child_category.parent_id)
    end

  end
end
