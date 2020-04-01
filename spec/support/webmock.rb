require 'webmock/rspec'

# Don't make calls to populate the Twitter widget during tests.
# (More generally, don't fail tests based on the availability of external
# services, and don't make a ton of external calls during tests.)
WebMock.disable_net_connect! allow_localhost: true
