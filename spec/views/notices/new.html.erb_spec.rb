require 'spec_helper'

describe 'notices/new.html.erb' do
  it "has a form for notices" do
    assign(:notice, Dmca.new)

    render

    expect(rendered).to have_css 'form'
  end

  Notice.type_models.each do |model|
    context "country selectors in \"#{model.label}\" notices" do
      it "use ISO country codes" do
        factory_name = model.name.tableize.singularize
        assign(
          :notice, build(factory_name, role_names: %w( sender recipient ))
        )

        render

        within(".recipient") do
          expect(page).to have_css("select option[value='us']")
        end

        within(".sender") do
          expect(page).to have_css("select option[value='us']")
        end
      end
    end
  end

  context "topic drop down" do
    it "shows the topics alphabetically" do
      second_topic = create(:topic, name: "B Topic")
      third_topic = create(:topic, name: "C Topic")
      first_topic = create(:topic, name: "A Topic")
      assign(:notice, Dmca.new)

      render

      within('select#notice_topic_ids') do
        expect(page).to have_nth_option(1, first_topic.name)
        expect(page).to have_nth_option(2, second_topic.name)
        expect(page).to have_nth_option(3, third_topic.name)
      end
    end

    private

    def have_nth_option(n, value)
      have_css("option:nth-child(#{n})", text: value)
    end
  end

  context "step headings" do
    it "has the correct step headings" do
      ordered_sections = %w( notice-body works sender recipient )
      assign(:notice, build(:dmca, role_names: %w( sender recipient )))

      render

      ordered_sections.each_with_index do |section, index|
        expect(page).to have_step_heading(section, index + 1)
      end
    end

    private

    def have_step_heading(section_class, step_number)
      have_css(".#{section_class} h4:contains('Step #{step_number}.')")
    end
  end

  context "tooltips" do
    factories = Notice::TYPES.map { |type| type.underscore.to_sym }

    factories.each do |factory|
      it "has the correct title tooltip for notice type #{factory}" do
        assign(:notice, build(factory))

        render

        within('.input.notice_title') do
          expect(page).to have_tooltip(
            "If the notice you sent/received had a subject line, enter it here"
          )
        end
      end

      it "has the correct action taken tooltip for notice type #{factory}" do
        assign(:notice, build(factory))

        render

        within('.input.notice_action_taken') do
          expect(page).to have_tooltip(
            "Did the recipient of the notice take action in response?"
          )
        end
      end
    end

    it "has the correct description tooltip for Trademark" do
      assign(:notice, build(:trademark))

      render

      within('.input.notice_works_description') do
        expect(page).to have_tooltip(
          "Description of allegedly infringed mark"
        )
      end
    end

    private

    def have_tooltip(tooltip)
      have_css("label[data-tooltip='#{tooltip}']")
    end
  end
end
