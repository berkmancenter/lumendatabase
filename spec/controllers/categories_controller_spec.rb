require 'spec_helper'

describe CategoriesController do
  it "loads the category by ID" do
    category = double("Category").as_null_object
    Category.should_receive(:find).with('42').and_return(category)

    get :show, id: 42

    expect(assigns(:category)).to eq category
    expect(response).to be_successful
    expect(response).to render_template(:show)
  end
end
