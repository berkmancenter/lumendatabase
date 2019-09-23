# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( rails_admin/rails_admin.css
                                                  rails_admin/rails_admin.js
                                                  rails_admin/custom/ui.js
                                                  piwik.js )

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# In case of node
# Rails.application.config.assets.paths << Rails.root.join('node_modules')
