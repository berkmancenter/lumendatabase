shared_examples "a categorizer of" do |categorized_model|
  it { should belong_to categorized_model }
  it { should belong_to :category }

  it {
    should validate_uniqueness_of(:category_id).
      scoped_to(:"#{categorized_model}_id")
  }
end
