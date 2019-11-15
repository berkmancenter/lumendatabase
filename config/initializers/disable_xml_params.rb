# Protect against injection attacks
# https://www.kb.cert.org/vuls/id/380039
ActionDispatch::Request.parameter_parsers.delete(Mime[:xml])
