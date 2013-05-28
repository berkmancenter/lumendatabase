# create three that we hold onto and reuse
dmca      = Category.create!(name: 'Anticircumvention (DMCA)')
bookmarks = Category.create!(name: 'Bookmarks')
chilling  = Category.create!(name: 'Chilling Effects')

category_names = [
  'Copyright',
  'Copyright and Fair Use',
  'Court Orders',
  'Defamation',
  'Derivative Works',
  'DMCA Notices',
  'DMCA Safe Harbor',
  'DMCA Subpoenas',
  'Documenting Your Domain Defense',
  'Domain Names and Trademarks',
  'E-Commerce Patents',
  'Fan Fiction',
  'International',
  'John Doe Anonymity',
  'Linking',
  'No Action',
  'Patent',
  'Piracy or Copyright Infringement',
  'Protest, Parody and Criticism Sites',
  'References',
  'Responses',
  'Reverse Engineering',
  'Right of Publicity',
  'Trade Secret',
  'Trademark',
  'UDRP',
  'Uncategorized'
]

category_names.each do |category_name|
  Category.create!(name: category_name)
end

CategoryManager.create!(
  name: "Harvard Law",
  categories: [dmca, bookmarks, chilling]
)

Submission.new(
  title: "Lion King on YouTube",
  date_sent: Time.now,
  category_ids: [dmca, bookmarks, chilling].map(&:id)
).save
