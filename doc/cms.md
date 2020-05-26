# CMS

Lumen uses [ComfortableMexicanSofa](https://github.com/comfy/comfortable-mexican-sofa/) to manage its blog and static pages.

The admin site is at `/cms_admin`.

## Privileges
Anyone with admin or super_admin privileges can access and use the admin site.

This policy can be adjusted in `app/models/ability.rb`.

`lib/cms_devise_auth.rb` checks to see whether a user can `:manage` the CMS
during the authentication process.

## Managing content

### To add a blog post:
* Click 'Add Child Page' next to 'blog_entries'
* Make sure to select the 'blawg' layout
* Fill out the fields
  * Don't change the prefilled 'parent' field
* 'slug' will be the end of the URL (lumendatabase.org/blog_entries/your-slug-here)
* 'image' can be any of the following: lightning, storm, rain, overcast, clouds, sunny, sunset, autumn, desert, tornado, snow (or you can leave it blank)

### To add a static page (like "about" or "researchers"):
* Click 'Add Child Page' next to 'pages'
* Fill out the fields

### To add links to the header or footer:
* Content of the 'page' type includes checkboxes for 'Link in Header' and 'Link in Footer'
* If you check these, the content will appear in the header/footer, respectively
* A few caveats:
  - The header and footer will not update immediately (due to page caching)
  - The text in the header/footer will be the text in the 'Page Title' field
  - You cannot control the order that the links appear in
  - This does not support putting blog posts into the header/footer. We could add that support via 1) updating the blog layout (see [notes on the pull request](https://github.com/berkmancenter/lumendatabase/pull/596)) and 2) updating the code so that it pulls the correct title -- the title fields for blogs and pages have different names due to CMS limitations.

### Extra details for the curious
You will also see an 'original_news_id' parent page (along with the 'blog_entries' and 'pages' parent pages). This exists to maintain permalinks for old versions of the content. Please don't touch it.

The left sidebar has several other options that you should not need but may be curious about:

'Snippets' lets you create chunks of content that you can then easily include/repeat in other pages.

'Files' lets you upload files that you can later include in your content.

'Sites' and 'Layouts' are configuration options that you should not change unless you know what you're doing. They have been set up for compatibility with earlier versions of the site, so you should not need to edit them. If you want to know what you're doing, check out the 'managing content' documentation here: https://github.com/comfy/comfortable-mexican-sofa/wiki
