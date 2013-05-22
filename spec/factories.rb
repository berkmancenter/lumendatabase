FactoryGirl.define do

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

end
