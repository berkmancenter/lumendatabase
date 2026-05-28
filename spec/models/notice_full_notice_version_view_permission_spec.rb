require 'spec_helper'

describe Notice do
  describe '#full_notice_version_view_permission' do
    it 'defaults to public' do
      expect(build(:dmca).full_notice_version_view_permission).to eq :public
    end

    it 'returns researchers when the researchers-only flag is set' do
      notice = build(:dmca, full_notice_version_only_researchers: true)

      expect(notice.full_notice_version_view_permission).to eq :researchers
    end

    it 'returns admins when the admins-only flag is set' do
      notice = build(:dmca, full_notice_version_only_lumen_team: true)

      expect(notice.full_notice_version_view_permission).to eq :admins
    end
  end

  describe '#full_notice_version_view_permission=' do
    it 'sets only the researchers-only flag for researchers' do
      notice = build(:dmca)

      notice.full_notice_version_view_permission = :researchers

      expect(notice.full_notice_version_only_researchers).to be true
      expect(notice.full_notice_version_only_lumen_team).to be false
    end

    it 'sets only the admins-only flag for admins' do
      notice = build(:dmca)

      notice.full_notice_version_view_permission = :admins

      expect(notice.full_notice_version_only_researchers).to be false
      expect(notice.full_notice_version_only_lumen_team).to be true
    end

    it 'clears both flags for public' do
      notice = build(
        :dmca,
        full_notice_version_only_researchers: true,
        full_notice_version_only_lumen_team: true
      )

      notice.full_notice_version_view_permission = :public

      expect(notice.full_notice_version_only_researchers).to be false
      expect(notice.full_notice_version_only_lumen_team).to be false
    end
  end
end
