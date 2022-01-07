require './lib/acts_as_taggable_on/comma_parser'

ActsAsTaggableOn.remove_unused_tags = true
# This hardcodes some behavior in the default parser which is more flexible,
# but results in a tremendous number of allocations (and we aren't using
# the flexibility).
ActsAsTaggableOn.default_parser = ActsAsTaggableOn::CommaParser
