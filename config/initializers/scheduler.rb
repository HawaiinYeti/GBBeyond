
require 'rufus-scheduler'

return unless defined?(Rails::Server)
  #
  # do not schedule when Rails is run from its console, for a test/spec, or
  # from a Rake task

# return if $PROGRAM_NAME.include?('spring')
  #
  # see https://github.com/jmettraux/rufus-scheduler/issues/186

s = Rufus::Scheduler.singleton

ActiveSupport::Reloader.to_prepare do
  # Clear locks on existing jobs on server start
  Delayed::Job.update_all(locked_by: nil, locked_at: nil)
  # Spawn a quick oneoff worker to pick up any oneoff jobs that may have been in progress
  spawn('QUEUE=oneoff bundle exec rails jobs:workoff')

  VideoSyncJob.perform_later(nil) if Video.all.size.zero?
  QueueJob.perform_later
end

s.every '1m' do
  ArchiveJob.perform_later unless Delayed::Job.where('handler LIKE ?', '%ArchiveJob%').exists?
end

s.every '5m' do
  ActiveRecord::Base.logger.silence do
    QueueJob.perform_now
  end
end

s.cron '1 0 * * *' do
  VideoSyncJob.perform_later
end

