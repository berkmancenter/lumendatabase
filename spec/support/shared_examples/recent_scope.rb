shared_examples 'an object with a recent scope' do
  let(:factory) { described_class.name.underscore }

  it "returns a limited number of records" do
    create_list(factory, described_class.recent_limit + 1)

    expect(described_class.recent.size).to eq described_class.recent_limit
  end

  it "returns records in descending created_at order" do
    third_record = Timecop.travel(16.hours.ago) { create(factory) }
    first_record = Timecop.travel(1.hour.ago) { create(factory) }
    second_record = Timecop.travel(10.hours.ago) { create(factory) }

    expect(described_class.recent).to eq [
      first_record, second_record, third_record
    ]
  end
end
