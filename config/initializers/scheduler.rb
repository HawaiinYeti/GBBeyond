
require 'rufus-scheduler'

return if defined?(Rails::Console) || Rails.env.test? || File.split($PROGRAM_NAME).last == 'rake'
  #
  # do not schedule when Rails is run from its console, for a test/spec, or
  # from a Rake task

# return if $PROGRAM_NAME.include?('spring')
  #
  # see https://github.com/jmettraux/rufus-scheduler/issues/186

s = Rufus::Scheduler.singleton

s.every '1m' do
  QueueJob.perform_later
end

s.cron '1 0 * * *' do
  VideoSyncJob.perform_later
end

ActiveSupport::Reloader.to_prepare do
  VideoSyncJob.perform_later(nil) if Video.all.size.zero?
end
