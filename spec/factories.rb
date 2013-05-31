FactoryGirl.define do

  sequence(:email) { |n| "user_#{n}@example.com" }

  sequence(:url) { |n| "http://example.com/url_#{n}" }

  factory :category do
    name "Category name"
  end

  factory :notice do
    title "A title"

    trait :with_body do
      body "A body"
    end

    trait :with_tags do
      before(:create) do |notice|
        notice.tag_list = 'a_tag, another_tag'
      end
    end

    trait :with_categories do
      before(:create) do |notice|
        notice.categories = build_list(:category, 3)
      end
    end

    trait :with_infringing_urls do # through works
      before(:create) do |notice|
        notice.works = build_list(:work, 3, :with_infringing_urls)
      end
    end

    factory :notice_with_notice_file do
      ignore do
        content "Content"
      end

      after(:create) do |notice, evaluator|
        create(
          :file_upload,
          kind: :notice,
          notice: notice,
          content: evaluator.content
        )
      end
    end

    factory :notice_with_entities do
      after(:create) do |notice|
        create(:entity_notice_role, notice: notice, entity: create(:entity))
      end
    end
  end

  factory :file_upload do
    ignore do
      content "Content"
    end

    file do
      Tempfile.open('factory_file') do |fh|
        fh.write(content)
        fh.flush

        Rack::Test::UploadedFile.new(fh.path, "text/plain")
      end
    end
  end

  factory :entity_notice_role do
    notice { build(:notice) }
    entity { build(:entity) }
    name { 'principal' }
  end

  factory :entity do
    name "A name"
    kind "individual"

    factory :entity_with_children do
      after(:create) do |parent_entity|
        create(:entity, parent: parent_entity)
        create(:entity, parent: parent_entity)
      end
    end

    factory :entity_with_notice_roles do
      after(:create) do |entity|
        notice = create(:notice)
        create(
          :entity_notice_role,
          entity: entity, notice: notice, name: 'principal'
        )
      end
    end
  end

  factory :user do
    email
    password "secretsauce"
    password_confirmation "secretsauce"
  end

  factory :relevant_question do
    question "What is the meaning of life?"
    answer "42"
  end

  factory :work do
    url
    description "Something copyrighted"

    trait :with_infringing_urls do
      before(:create) do |work|
        work.infringing_urls = build_list(:infringing_url, 3)
      end
    end
  end

  factory :infringing_url do
    url
  end

end
