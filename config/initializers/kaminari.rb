# Prevents conflicts between Kaminari (used by rails_admin) and
# will_paginate.
Kaminari.configure do |config|
  config.page_method_name = :per_page_kaminari
end
