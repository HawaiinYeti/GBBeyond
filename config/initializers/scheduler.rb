
require 'rufus-scheduler'

return unless defined?(Rails::Server)
  #
  # do not schedule when Rails is run from its console, for a test/spec, or
  # from a Rake task

# return if $PROGRAM_NAME.include?('spring')
  #
  # see https://github.com/jmettraux/rufus-scheduler/issues/186

s = Rufus::Scheduler.singleton

s.every '30s' do
  QueueJob.perform_now
end

s.cron '1 0 * * *' do
  VideoSyncJob.perform_later
end

ActiveSupport::Reloader.to_prepare do
  VideoSyncJob.perform_later(nil) if Video.all.size.zero?
end
