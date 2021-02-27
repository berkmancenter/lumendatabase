class AddFullNoticeOnlyResearchersToEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :entities_full_notice_only_researchers_users do |t|
      t.references :entity, index: true
      t.references :user, index: false
    end

    add_column :entities, :full_notice_only_researchers, :boolean

    Comfy::Cms::Snippet.create!(
      identifier: 'lumen_notice_only_full_for_researchers',
      label: 'Full for researchers only text on notice view',
      content: 'Thanks for your interest, but URLs from submitter <span class="lumen-badge">###SUBMITTER_NAME###</span> are viewable only by users with a Lumen researcher credential.',
      site: Comfy::Cms::Site.first
    )
  end
end
