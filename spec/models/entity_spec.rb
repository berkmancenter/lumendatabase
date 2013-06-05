require "spec_helper"

describe Entity do
  context 'schema_validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :kind }
    it { should ensure_length_of(:address_line_1).is_at_most(255) }
  end

  it { should have_many(:entity_notice_roles).dependent(:destroy) }
  it { should have_many(:notices).through(:entity_notice_roles)  }
  it { should ensure_inclusion_of(:kind).in_array(Entity::KINDS) }

  context "hierarchical relationships" do
    it "can have child entities" do
      entity = create(:entity, :with_children)
      expect(entity.children).to be
    end

    it "does not allow a node with children to be destroyed" do
      entity = create(:entity, :with_children)
      expect { entity.destroy }.to raise_error(Ancestry::AncestryException)
    end
  end

end
