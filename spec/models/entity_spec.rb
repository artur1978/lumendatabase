require "spec_helper"

describe Entity do
  context 'automatic validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :kind }
    it { should ensure_length_of(:address_line_1).is_at_most(255) }
    it { should validate_uniqueness_of(:name) }
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

  context "#addressed?" do
    it "returns false when all address fields are empty" do
      entity = Entity.new

      expect(entity).to_not be_addressed
    end

    Entity::ADDRESS_FIELDS.each do |field|
      it "returns true when '#{field}' is present" do
        entity = Entity.new(field => "not-empty")

        expect(entity).to be_addressed
      end
    end
  end

end
