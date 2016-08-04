# Paperclip didn't support MIME types with dots until 4.1.2
# Lumen is on 3.5 and 4.x isn't easily compatible with 3.x
# Adding a kludge here for now
# https://github.com/thoughtbot/paperclip/issues/1550
Paperclip::DataUriAdapter.send :remove_const, 'REGEXP'
Paperclip::DataUriAdapter::REGEXP = /\Adata:([-\w]+\/[-\w\+\.]+)?;base64,(.*)/m
