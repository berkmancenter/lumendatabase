class AddCmsSnippet < ActiveRecord::Migration[5.2]
  def change
    Comfy::Cms::Snippet.create!(
      identifier: 'lumen_notice_only_full_for_specific_researchers',
      label: 'Full for specific researchers only text on notice view',
      content: 'Thanks for your interest, but URLs from submitter <span class="lumen-badge">###SUBMITTER_NAME###</span> are viewable only by selected accredited researchers.',
      site: Comfy::Cms::Site.first
    )
  end
end
