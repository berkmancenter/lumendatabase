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
* Fill out the fields
  * Don't change the prefilled 'parent' and 'layout' fields
* 'slug' will be the end of the URL (lumendatabase.org/blog_entries/your-slug-here)
* 'image' can be any of the following: lightning, storm, rain, overcast, clouds, sunny, sunset, autumn, desert, tornado, snow (or you can leave it blank)

### To add a static page (like "about" or "researchers"):
* Click 'Add Child Page' next to 'pages'
* Fill out the fields

### Extra details for the curious
You will also see an 'original_news_id' parent page (along with the 'blog_entries' and 'pages' parent pages). This exists to maintain permalinks for old versions of the content. Please don't touch it.

The left sidebar has several other options that you should not need but may be curious about:

'Snippets' lets you create chunks of content that you can then easily include/repeat in other pages.

'Files' lets you upload files that you can later include in your content.

'Sites' and 'Layouts' are configuration options that you should not change unless you know what you're doing. They have been set up for compatibility with earlier versions of the site, so you should not need to edit them. If you want to know what you're doing, check out the 'managing content' documentation here: https://github.com/comfy/comfortable-mexican-sofa/wiki
