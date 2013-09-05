user_levels = [
  ['user@chillingeffects.org',        []],
  ['submitter@chillingeffects.org',   [Role.submitter]],
  ['redactor@chillingeffects.org',    [Role.redactor]],
  ['publisher@chillingeffects.org',   [Role.publisher]],
  ['admin@chillingeffects.org',       [Role.admin]],
  ['super_admin@chillingeffects.org', [Role.super_admin]],
  ['adam@chillingeffects.org',        [Role.super_admin]],
  ['wendy@chillingeffects.org',       [Role.super_admin]],
  ['djcp@thoughtbot.com',             [Role.super_admin]],
  ['matt@thoughtbot.com',             [Role.super_admin]],
  ['pat@thoughtbot.com',              [Role.super_admin]],
  ['phil@thoughtbot.com',             [Role.super_admin]],
]

user_levels.each do |email, roles|
  User.create!(
    email: email,
    roles: roles,
    password: 'password',
  )
end

google = User.create!(
  email: 'admin@google.com',
  roles: [Role.submitter],
  password: 'password'
)

twitter = User.create!(
  email: 'admin@twitter.com',
  roles: [Role.submitter],
  password: 'password'
)

Entity.create!(
  kind: 'organization',
  name: 'Google',
  address_line_1: '1600 Amphitheatre Parkway',
  city: 'Mountain View',
  state: 'CA',
  zip: '94043',
  country_code: 'US',
  user: google
)

Entity.create!(
  kind: 'organization',
  name: 'Twitter, Inc.',
  address_line_1: '100 Maple Leaf Rd.',
  city: 'Quebec',
  state: 'ON',
  zip: 'FFF 222',
  country_code: 'CA',
  user: twitter
)
