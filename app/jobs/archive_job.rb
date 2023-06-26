class ArchiveJob < ApplicationJob
  queue_as :default

  def perform()
    return unless Setting.archive_path.present?

    current_videos = Channel.where(archive_videos: true).
                     map { |x| x.current_queue_item&.video if !x.current_queue_item&.video.archived }.uniq.compact
    current_videos.each do |video|
      video.archive_video
    end
  end
end
