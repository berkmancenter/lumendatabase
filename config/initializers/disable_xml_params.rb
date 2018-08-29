# Protect against injection attacks
# https://www.kb.cert.org/vuls/id/380039
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
