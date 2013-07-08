%w(

  admin@example.com
  pat@thoughtbot.com

).each do |email|
  User.create!(
    email: email,
    password: 'password',
    password_confirmation: 'password'
  )
end
