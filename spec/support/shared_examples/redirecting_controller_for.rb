shared_examples 'a redirecting controller for' do |model_class, factory_name, id_method|
  it "redirects to a #{model_class} according to #{id_method}" do
    instance = build(factory_name, id: 1000)
    expect(model_class).to receive(id_method).with('2000').and_return(instance)

    get :show, id: 2000

    expect(response).to redirect_to("/#{model_class.name.tableize}/1000")
      expect(response.code).to eq "301"
  end

  it "gives a 404 when a mapping isn't found" do
    expect(model_class).to receive(id_method).and_return(nil)
    
    get :show, id: 2000
    
    expect(response.code).to eq "404"
  end
end
