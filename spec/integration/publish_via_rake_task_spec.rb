require 'rails_helper'
require 'rake'

feature "Publishing notices via rake task" do
  def notice_statuses
    Notice.all.map{|n| [n.publication_delay, n.published]}.sort_by(&:first)
  end

  context "Notices that need publishing" do
    scenario "get published" do
      notices = build_list(:dmca, 3)
      delays = [20, 40, 60]
      delays.each_with_index do |delay, i|
        user = create(:user, :submitter, :with_entity, publication_delay: delay.seconds)
        role = notices[i].entity_notice_roles.build(name: 'submitter')
        role.entity = user.entity
        role.save
        notices[i].save
      end

      expect(Notice.pluck(:published)).to match_array([false, false, false])

      Chill::Application.load_tasks

      Timecop.freeze(30.seconds.from_now) do
        Rake::Task['chillingeffects:publish_embargoed'].invoke
        expected_statuses = [[20, true], [40, false], [60, false]]
        expect(notice_statuses).to match_array(expected_statuses)
      end

      Rake::Task['chillingeffects:publish_embargoed'].reenable

      Timecop.freeze(41.seconds.from_now) do
        Rake::Task['chillingeffects:publish_embargoed'].invoke
        expected_statuses = [[20, true], [40, true], [60, false]]
        expect(notice_statuses).to match_array(expected_statuses)
      end

      Rake::Task['chillingeffects:publish_embargoed'].reenable

      Timecop.freeze(60.seconds.from_now) do
        Rake::Task['chillingeffects:publish_embargoed'].invoke
        expected_statuses = [[20, true], [40, true], [60, true]]
        expect(notice_statuses).to match_array(expected_statuses)
      end
    end
  end
end

