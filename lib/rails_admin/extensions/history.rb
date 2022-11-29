# frozen_string_literal: true

require 'rails_admin/extensions/history/auditing_adapter'

RailsAdmin.add_extension(:history, RailsAdmin::Extensions::History, auditing: true)
