user_levels = [
  ['redactor@chillingeffects.org',    Role.redactor],
  ['publisher@chillingeffects.org',   Role.publisher],
  ['admin@chillingeffects.org',       Role.admin],
  ['super_admin@chillingeffects.org', Role.super_admin],
  ['pat@thoughtbot.com',              Role.super_admin]
]

user_levels.each do |email, role|
  User.create!(
    email: email,
    roles: [role],
    password: 'password',
  )
end
