class ArchiveJob < ApplicationJob
  queue_as :default

  def perform()
    return unless Setting.archive_path.present?

    if Setting.archive_method == 'Playback'
      Channel.where(archive_videos: true).
        map { |x| x.current_queue_item&.video unless x.current_queue_item&.video.archived }.
        uniq.compact.
        each(&:archive_video)
    elsif Setting.archive_method == 'Continuous'
      Channel.where(archive_videos: true).
        map { |x| x.videos.where(archived: false).last }.uniq.compact.
        each(&:archive_video)
    end
  end
end
