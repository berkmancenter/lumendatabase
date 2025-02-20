require 'ostruct'
require 'spec_helper'

describe 'Rack::Attack::Request' do
  it 'recognizes localhost (IPv6)' do
    req = Rack::Attack::Request.new(spec_env({"REMOTE_ADDR"=>"::1"}))
    expect(req.localhost?).to be true
  end

  it 'recognizes localhost (IPv4)' do
    req = Rack::Attack::Request.new(spec_env({"REMOTE_ADDR"=>"127.0.0.1"}))
    expect(req.localhost?).to be true
  end

  it 'recognizes admins identified by login' do
    user = create(:user, :admin)
    env = spec_env
    authenticate(user, env)
    req = Rack::Attack::Request.new(env)
    expect(req.admin?).to be true
  end

  it 'recognizes admins identified by token' do
    user = create(:user, :admin)
    notice = create(:dmca)
    req = Rack::Attack::Request.new(
      spec_env(
        uri: "/notices/#{notice.id}?authentication_token=#{user.authentication_token}"
      )
    )
    expect(req.admin?).to be true
  end

  it 'recognizes superadmins' do
    user = create(:user, :super_admin)
    env = spec_env
    authenticate(user, env)
    req = Rack::Attack::Request.new(env)
    expect(req.admin?).to be true
  end

  it 'does not recognize admins when there is no user' do
    req = Rack::Attack::Request.new(spec_env)
    expect(req.admin?).to be false
  end

  it 'does not recognize admins when the user is not an admin' do
    user = create(:user)
    env = spec_env
    authenticate(user, env)
    req = Rack::Attack::Request.new(env)
    expect(req.admin?).to be false
  end

  it 'recognizes submitters' do
    user = create(:user, :submitter)
    env = spec_env
    authenticate(user, env)
    req = Rack::Attack::Request.new(env)
    expect(req.submitter?).to be true
  end

  it 'recognizes non-submitters' do
    user = create(:user)
    env = spec_env
    authenticate(user, env)
    req = Rack::Attack::Request.new(env)
    expect(req.submitter?).to be false
  end

  it 'recognizes when users are authenticated by token' do
    user = create(:user)
    notice = create(:dmca)
    req = Rack::Attack::Request.new(
      spec_env(
        {uri: "/#{notice.id}?authentication_token=#{user.authentication_token}"}
      )
    )
    expect(req.authenticated?).to be true
  end

  it 'recognizes when users are authenticated by login' do
    user = create(:user)
    env = spec_env
    authenticate(user, env)
    req = Rack::Attack::Request.new(env)
    expect(req.authenticated?).to be true
  end

  it 'extracts tokens from headers' do
    token = 'beep'
    req = Rack::Attack::Request.new(
      spec_env(
        {'HTTP_X_AUTHENTICATION_TOKEN' => token}
      )
    )
    expect(req.token).to eq token
  end

  it 'extracts tokens from params' do
    token = 'token'
    req = Rack::Attack::Request.new(
      spec_env(uri: "/?authentication_token=#{token}")
    )
    expect(req.token).to eq token
  end

  # Rack::Attack::Request must be initialized with an env. Rack has already
  # done the work of providing a valid env that can be used in tests.
  def spec_env(options = {})
    uri = options.delete(:uri) || '/'
    env = Rack::MockRequest.env_for(uri, options)
    env['warden'] = OpenStruct.new
    env
  end

  def authenticate(user, env)
    env['warden'].user = user
  end
end
