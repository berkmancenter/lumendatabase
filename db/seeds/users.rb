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
