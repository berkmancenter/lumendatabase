# This is used by the rake task that perfoms the initial import of blog posts
# during the migration to the CMS, but it's also used by the test suite to
# rapidly set up blog posts with identical properties, so don't get rid of it
# post-migration.
class BlogPostFactory
  def initialize(site, layout, parent, entry: nil, seed: 1)
    @seed = seed
    @entry = entry || fake_entry
    @site = site
    @layout = layout
    @parent = parent
  end

  def manufacture
    page
    fields_to_formats.keys.each do |key|
      make_fragment(key)
    end
  end

  def page
    @page ||= Comfy::Cms::Page.create(
      slug: @entry.id,
      label: @entry.title,
      created_at: @entry.created_at,
      updated_at: Time.now,
      is_published: true,
      site: @site,
      layout: @layout,
      parent: @parent
    )
  end

  def fields_to_formats
    {
      'author': 'text',
      'title': 'text',
      'abstract': 'wysiwyg',
      'image': 'text',
      'content': 'wysiwyg'
    }
  end

  def content_function(identifier)
    if [:content, :abstract].include? identifier
      "#{identifier}_html"
    else
      identifier
    end
  end

  def make_fragment(identifier)
    Comfy::Cms::Fragment.create(
      record: page,
      identifier: identifier,
      tag: fields_to_formats[identifier],
      content: @entry.send(content_function(identifier))
    )
  end

  def fake_entry
    entry = OpenStruct.new
    entry.id = @seed
    entry.title = "page_#{@seed}"
    entry.created_at = @seed.days.ago
    entry.author = 'John Rock'
    entry.abstract_html = "<p>abstract #{@seed}</p>"
    entry.image = 'overcast'
    entry.content_html = "<p>content #{@seed}</p>"
    entry
  end
end
