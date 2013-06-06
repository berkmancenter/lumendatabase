FactoryGirl.define do

  sequence(:email) { |n| "user_#{n}@example.com" }

  sequence(:url) { |n| "http://example.com/url_#{n}" }

  factory :category do
    name "Category name"
  end

  factory :notice do
    title "A title"
    works { build_list(:work, 1) }

    ignore do
      role_names ['principal']
    end

    after :build do |notice, evaluator|
      evaluator.role_names.each do |role_name|
        notice.entity_notice_roles <<
          build(:entity_notice_role, notice: notice, name: role_name)
      end
    end

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
    notice
    entity
    name 'principal'
  end

  factory :entity do
    name "A name"
    kind "individual"
    address_line_1 "Address 1"
    address_line_2 "Address 2"
    city "City"
    state "State"
    zip "01222"
    country_code "US"
    phone "555-555-1212"
    email "foo@example.com"
    url "http://www.example.com"

    trait :with_children do
      after(:create) do |parent_entity|
        create(:entity, parent: parent_entity)
        create(:entity, parent: parent_entity)
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

  factory :blog_entry do
    title "Blog title"
    author "John Smith"

    trait :published do
      published_at 5.days.ago
    end

    trait :with_abstract do
      abstract "Some summary of the post's content"
    end

    trait :with_content do
      content "Some *markdown* content"
    end
  end

end
