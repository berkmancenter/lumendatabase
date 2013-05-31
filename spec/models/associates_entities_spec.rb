require 'spec_helper'

describe AssociatesEntities do

  context '#associater' do
    it 'does nothing if there are no valid entities' do
      entity_params = nil
      associater = described_class.new(entity_params, double(), double())

      Entity.should_not_receive(:new)
      EntityNoticeRole.should_not_receive(:new)

      associater.associate_entity_models
    end

    it 'initializes an Entity with the correct metadata' do
      Entity.should_receive(:new).with(
        example_entity.slice(*entity_specific_params)
      )
      with_valid_associater do |associater, notice, submission|
        associater.associate_entity_models
      end
    end

    it 'initializes the EntityNoticeRole correctly' do
      with_valid_associater do |associater, notice, submission|
        entity_instance = Entity.new
        Entity.stub(:new).and_return(entity_instance)
        EntityNoticeRole.should_receive(:new).with(
          notice: notice, name: example_entity[:role], entity: entity_instance
        )
        associater.associate_entity_models
      end
    end

    it 'appends the correct models to Submission#models' do
      with_valid_associater do |associater, notice, submission|
        associater.associate_entity_models
        expect(submission.models.detect { |m| m.is_a?(Entity) }).to be
        expect(submission.models.detect { |m| m.is_a?(EntityNoticeRole) }).to be
      end
    end
  end

  private

  def example_entity
    { name: 'An entity name',
      role: 'submitter',
      address_line_1: '17 Foobar ave',
      address_line_2: 'Suite 1337',
      city: 'Fooville',
      state: 'MA',
      country_code: 'US',
      phone: '781-555-1212',
      email: 'entity@example.com',
      url: 'http://www.example.com'
    }
  end

  def entity_specific_params
    [
      :name, :kind, :address_line_1, :address_line_1, :address_line_2,
      :city, :state, :country_code, :phone, :email, :url
    ]
  end


  def with_valid_associater
    entity_params = [
      example_entity
    ]
    notice = Notice.new
    submission = Submission.new
    associater = described_class.new(entity_params, notice, submission)
    yield associater, notice, submission
  end
end
