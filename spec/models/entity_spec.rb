require "spec_helper"

describe Entity do
  it { should validate_presence_of :name }
  it { should validate_presence_of :kind }
  it { should have_many :entity_notice_roles }
  it { should have_many(:notices).through(:entity_notice_roles)  }
  it { should ensure_inclusion_of(:kind).in_array(Entity::KINDS) }

  context "hierarchical relationships" do
    it "can have child entities" do
      entity = create(:entity_with_children)
      expect{ entity.children }.to be
    end

    it "does not allow a node with children to be destroyed" do
      entity = create(:entity_with_children)
      expect{ entity.destroy }.to raise_error(Ancestry::AncestryException)
    end
  end

  context "notice roles" do
    it "cleans up notice roles after an entity is destroyed" do
      entity = create(:entity_with_notice_roles)
      EntityNoticeRole.any_instance.should_receive(:destroy)
      entity.destroy
    end
  end
end
