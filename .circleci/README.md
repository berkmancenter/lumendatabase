The following must be set in the circleci environment:

`CLIVER_NO_VERIFY=1`
  This prevents Cliver (a poltergeist dependency) from complaining about
  a phantomjs version mismatch when it erroneously checks the version. We're
  explicitly installing a correct version of phantomjs, so we don't need to
  check.
`COVERALLS_REPO_TOKEN=<get this from coveralls>`
