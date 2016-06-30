require 'spec_helper'
require 'ingestor'

describe Ingestor::Legacy::AttributeMapper do
  context "#notice_type" do
    it "returns the notice_type of its importer" do
      importer = double("Importer")
      importer.stub(:notice_type).and_return(Trademark)
      Ingestor::ImportDispatcher.stub(:for).and_return(importer)

      mapper = described_class.new({})

      expect(mapper.notice_type).to eq Trademark
    end
  end

  context "with empty Subjects" do
    [nil, '', ' ', "\n "].each do |value|
      it "sets the Title from Re_Line when Subject is #{value.inspect}" do
        hash = {
          'Subject' => value,
          'Re_Line' => 'The Subject',
        }

        attributes = described_class.new(hash).mapped
        expect(attributes[:title]).to eq 'The Subject'
      end

      it "sets the Title to \"Untitled\" when Re_Line is #{value.inspect}" do
        hash = {
          'Subject' => nil,
          'Re_Line' => value,
        }

        attributes = described_class.new(hash).mapped
        expect(attributes[:title]).to eq 'Untitled'
      end
    end

  end

  it "maps basic metadata" do
    hash = {
      'NoticeID' => '1',
      'Subject' => 'The Title',
      'Re_Line' => 'The Subject',
      'How_Sent' => 'online form: Form',
      'add_date' => '2013-07-01 00:06:00 -0400',
      'alter_date' => '2013-07-02 00:07:00 -0400',
      'Date' => '2013-07-01',
      'Readlevel' => '0'
    }

    attributes = described_class.new(hash).mapped

    expect(attributes[:original_notice_id]).to eq hash['NoticeID']
    expect(attributes[:title]).to eq hash['Subject']
    expect(attributes[:subject]).to eq hash['Re_Line']
    expect(attributes[:source]).to eq hash['How_Sent']
    expect(attributes[:created_at]).to eq hash['add_date']
    expect(attributes[:updated_at]).to eq hash['alter_date']
    expect(attributes[:date_sent]).to eq hash['Date']
    expect(attributes[:date_received]).to eq hash['Date']
    expect(attributes[:rescinded]).to be_falsey
    expect(attributes[:hidden]).to be_falsey
    expect(attributes[:mark_registration_number]).to be_empty
  end

  context "created_at" do
    [nil, '0000-00-00 00:00:00'].each do |date|
      it "comes from alter_date if add_date is #{date}" do
        hash = {
          'add_date' => date,
          'alter_date' => '2013-07-02 00:07:00 -0400'
        }

        attributes = described_class.new(hash).mapped

        expect(attributes[:created_at]).to eq hash['alter_date']
      end
    end
  end

  context "when works are found" do
    before do
      @import_class = double(
        "ImportClass",
        works: 'works',
        file_uploads: 'files',
        action_taken: 'Yes',
        require_review_if_works_empty?: true,
        entities: {},
        default_recipient: nil,
        default_submitter: nil,
        mark_registration_number: nil,
        body: nil,
        body_original: nil,
        hidden?: nil,
        review_required?: false,
        tag_list: nil,
        date_received: nil,
        sender_address: nil,
        recipient: nil
      )
    end

    it "loads works and files using Ingester::ImportDispatcher" do
      hash = {
        'OriginalFilePath' => 'path',
        'SupportingFilePath' => 'other path'
      }
      Ingestor::ImportDispatcher.
        should_receive(:for).with('path', 'other path').and_return(@import_class)

      attributes = described_class.new(hash).mapped

      expect(attributes[:works]).to eq 'works'
      expect(attributes[:file_uploads]).to eq 'files'
      expect(attributes[:review_required]).to eq false
    end

    it "does pass through the Body value" do
      Ingestor::ImportDispatcher.should_receive(:for).and_return(@import_class)

      attributes = described_class.new({ 'Body' => 'foobar' }).mapped

      expect(attributes[:body]).to eq('foobar')
    end
  end

  context "mark_registration_numbers" do
    it "valid mark_registration_numbers are passed through" do
      stub_importer_with_no_works

      attributes = described_class.new({}).mapped

      expect(attributes[:works]).to eq [Work.unknown]
    end
  end

  context "when works are not found" do
    it "assigns the unknown work" do
      stub_importer_with_no_works

      attributes = described_class.new({}).mapped

      expect(attributes[:mark_registration_number]).to eq 10000
    end

    it "passes through the Body so there is some content" do
      stub_importer_with_no_works

      attributes = described_class.new(
        { 'Body' => "foobar", "BodyOriginal" => "barfoo" }
      ).mapped

      expect(attributes[:body]).to eq 'foobar'
      expect(attributes[:body_original]).to eq 'barfoo'
    end

    it "flags the notice for review" do
      stub_importer_with_no_works

      attributes = described_class.new({}).mapped

      expect(attributes[:review_required]).to eq true
    end

    it "does not flag the notice for review if the importer says not to" do
      stub_importer_with_no_works(false)

      attributes = described_class.new({}).mapped

      expect(attributes[:review_required]).to eq false
    end
  end

  %w( Sender Recipient ).each do |role_name|
    it "creates a valid address for #{role_name}" do
      hash = {
        "Sender_LawFirm" => "Not nil",
        "Recipient_Entity" => "Not nil",
        "#{role_name}_Address1" => 'address 1',
        "#{role_name}_Address2" => 'address 2',
        "#{role_name}_City" => 'city',
        "#{role_name}_State" => 'state',
        "#{role_name}_Zip" => 'zip',
        "#{role_name}_Country" => 'US',
      }

      attributes = described_class.new(hash).mapped

      entity = find_entity_notice_role(attributes, role_name.downcase).entity
      expect(entity.address_line_1).to eq hash["#{role_name}_Address1"]
      expect(entity.address_line_2).to eq hash["#{role_name}_Address2"]
      expect(entity.city).to eq hash["#{role_name}_City"]
      expect(entity.state).to eq hash["#{role_name}_State"]
      expect(entity.zip).to eq hash["#{role_name}_Zip"]
      expect(entity.country_code).to eq hash["#{role_name}_Country"]
    end
  end

  it "creates a sender entity from Sender_LawFirm" do
    hash = {
      'Sender_LawFirm' => 'the entity',
    }

    attributes = described_class.new(hash).mapped

    entity = find_entity_notice_role(attributes, 'sender').entity
    expect(entity.name).to eq hash['Sender_LawFirm']
  end

  it "removes extraenous fields from entity names" do
    [
      %q|Electronic Arts Inc. ("EA")
contact_email_noprefill: info.antipiracy@dtecnet.com|,
%q|Electronic Arts Inc. ("EA")url_box3: http://example.com|

    ].each do |entity_name|
      hash = {
        'Sender_LawFirm' => entity_name
      }

      attributes = described_class.new(hash).mapped

      entity = find_entity_notice_role(attributes, 'sender').entity
      expect(entity.name).to eq %Q|Electronic Arts Inc. ("EA")|
    end
  end

  context "entity name quirks" do
    it "does not create entities when the name is only whitespace" do
      hash = {
        'Sender_LawFirm' => " \n \n    ",
      }

      attributes = described_class.new(hash).mapped
      expect(attributes[:entity_notice_roles]).to be_blank
    end
  end

  context "with sender and principal entities" do
    it "removes 'on behalf of'" do
      hash = {
        'Sender_LawFirm' => 'The sender on behalf of the entity',
        'Sender_Principal' => 'The entity',
      }

      attributes = described_class.new(hash).mapped

      sender = find_entity_notice_role(attributes, 'sender').entity
      expect(sender.name).to eq 'The sender'

      principal = find_entity_notice_role(attributes, 'principal').entity
      expect(principal.name).to eq 'The entity'
    end

    it "does not modify sender when there's no 'on behalf of'" do
      hash = {
        'Sender_LawFirm' => 'The sender',
        'Sender_Principal' => 'The entity',
      }

      attributes = described_class.new(hash).mapped

      sender = find_entity_notice_role(attributes, 'sender').entity
      expect(sender.name).to eq 'The sender'

      principal = find_entity_notice_role(attributes, 'principal').entity
      expect(principal.name).to eq 'The entity'
    end
  end

  it "creates a principal entity from Sender_Principal" do
    hash = {
      'Sender_Principal' => 'the entity',
    }

    attributes = described_class.new(hash).mapped

    entity = find_entity_notice_role(attributes, 'principal').entity
    expect(entity.name).to eq hash['Sender_Principal']
  end

  it "creates a recipient entity from the Recipient_Entity" do
    hash = {
      'Recipient_Entity' => 'the entity',
    }

    attributes = described_class.new(hash).mapped

    entity = find_entity_notice_role(attributes, 'recipient').entity
    expect(entity.name).to eq hash['Recipient_Entity']
  end

  it "creates an attorney entity from Sender_Attorney" do
    hash = {
      'Sender_Attorney' => 'the entity',
    }

    attributes = described_class.new(hash).mapped

    entity = find_entity_notice_role(attributes, 'attorney').entity
    expect(entity.name).to eq hash['Sender_Attorney']
  end

  it "uses entities from the importer when none are in the hash" do
    import_class = double(
      "ImportClass",
      works: [],
      file_uploads: [],
      action_taken: 'yes',
      require_review_if_works_empty?: true,
      entities: { sender: 'Sender' },
      default_recipient: nil,
      default_submitter: nil,
      mark_registration_number: nil,
      body: nil,
      body_original: nil,
      hidden?: nil,
      review_required?: false,
      tag_list: nil,
      date_received: nil,
      sender_address: nil,
      recipient: nil
    )
    Ingestor::ImportDispatcher.stub(:for).and_return(import_class)
    import_class.should_receive(:entities).exactly(4).times

    attributes = described_class.new({}).mapped
    entity = find_entity_notice_role(attributes, 'sender').entity
    expect(entity.name).to eq 'Sender'
  end

  it "correctly interprets different country codes" do
    [' USA', 'US', 'us', 'United States', 'USA'].each do |country_code|
      hash = {
        "Sender_LawFirm" => "Not nil",
        "Sender_Country" => country_code,
      }

      attributes = described_class.new(hash).mapped

      entity = find_entity_notice_role(attributes, 'sender').entity
      expect(entity.country_code.downcase).to eq 'us'
    end
  end

  context "ExcludedNoticeError" do
    it "can be raised with an informative message" do
      begin
        raise described_class::ExcludedNoticeError, "I said so"
      rescue => ex
        expect(ex.message).to eq "Notice was excluded because I said so"
      end
    end

    spam_senders = [
      "http://lindasomething",
      "http://lindaanything",
      "www.lindasomething.com",
      "www.lindaanything.com",
      "Stephen Darori"
    ]

    spam_senders.each do |sender_name|
      it "is raised for Sender #{sender_name} when to Google" do
        hash = {
          "Sender_Principal" => sender_name,
          "Recipient_Entity" => "Google Something"
        }

        expect {

          described_class.new(hash)

        }.to raise_error(described_class::ExcludedNoticeError)
      end

      it "is not raised for Sender #{sender_name} when not to Google" do
        hash = {
          "Sender_Principal" => sender_name,
          "Recipient_Entity" => "Not Google"
        }

        expect {

          described_class.new(hash)

        }.not_to raise_error
      end
    end

    it "is raised for for Readlevel 9" do
      expect {

        described_class.new("Readlevel" => "9")

      }.to raise_error(described_class::ExcludedNoticeError)
    end
  end

  context "using Readlevel" do
    it "marks a notice as rescinded if Readlevel is 10" do
      attributes = described_class.new("Readlevel" => "10").mapped

      expect(attributes[:rescinded]).to be true
    end

    it "marks a notice as hidden if Readlevel is 8" do
      attributes = described_class.new("Readlevel" => "8").mapped

      expect(attributes[:hidden]).to be true
    end

    it "marks a notice as hidden if Readlevel is 3" do
      attributes = described_class.new("Readlevel" => "3").mapped

      expect(attributes[:hidden]).to be true
    end

    it "also handles integer Readlevels" do
      attributes = described_class.new("Readlevel" => 3).mapped

      expect(attributes[:hidden]).to be true
    end
  end

  def find_entity_notice_role(attributes, role_name)
    attributes[:entity_notice_roles].find do |entity_notice_role|
      entity_notice_role.name == role_name
    end
  end

  def stub_importer_with_no_works(review_required = true)
    stubbed_methods = {
      works: [],
      file_uploads: [],
      action_taken: nil,
      require_review_if_works_empty?: review_required,
      entities: {},
      default_recipient: nil,
      default_submitter: nil,
      mark_registration_number: 10000,
      body: nil,
      body_original: nil,
      hidden?: nil,
      review_required?: false,
      tag_list: nil,
      date_received: nil,
      sender_address: nil,
      recipient: nil
    }
    Ingestor::ImportDispatcher.stub(:for).and_return(double(
      "ImportClass", stubbed_methods
    ))
  end
end
