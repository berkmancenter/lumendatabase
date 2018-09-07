#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be
# available to Rake.

require File.expand_path('../config/application', __FILE__)

Chill::Application.load_tasks

if defined?(RSpec)
  task(:spec).clear

  desc 'Run ingestor specs'
  RSpec::Core::RakeTask.new(:ingestor) do |t|
    t.pattern = 'spec/lib/ingestor/**/*_spec.rb'
  end

  desc 'Run specs excluding elasticsearch'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--tag "~search"'
  end

  desc 'Run all specs'
  RSpec::Core::RakeTask.new(:all)
end

task(:default).clear
task default: :all
