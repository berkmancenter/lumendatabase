shared_examples 'an object with hierarchical relationships' do
  it "can have child entities" do
    instance = create(factory_name, :with_children)

    expect(instance.children).to be
  end

  it "does not allow a node with children to be destroyed" do
    entity = create(factory_name, :with_children)

    expect { entity.destroy }.to raise_error(Ancestry::AncestryException)
  end

  it "has a parent_enum value that does not include itself" do
    instance = create(factory_name)
    another_instance = create(factory_name)

    expect(instance.parent_enum.map{|r| r[1]}).not_to include(instance.id)
  end

  def factory_name
    described_class.to_s.downcase.to_sym
  end
end
