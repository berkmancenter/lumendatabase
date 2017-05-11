shared_examples "a topic assigner of" do |topic_assigned_model|
  it { is_expected.to belong_to topic_assigned_model }
  it { is_expected.to belong_to :topic }

  it {
    is_expected.to validate_uniqueness_of(:topic_id).
      scoped_to(:"#{topic_assigned_model}_id")
  }
end
