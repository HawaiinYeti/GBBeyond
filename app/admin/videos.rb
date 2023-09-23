ActiveAdmin.register Video do
  menu priority: 4

  controller do
    def scoped_collection
      super.eager_load :show
    end
  end

  actions :all, except: [:new, :edit, :destroy]

  action_item only: :index do
    running = Delayed::Job.where("handler LIKE '%VideoSyncJob%'").size.positive?

    link_to 'Sync Videos', sync_videos_path,
            class: (running ? 'disabled' : ''),
            title: (running ? 'Job is currently running' : '')
  end

  member_action :archive, method: :put do
    resource.delay(queue: 'oneoff').archive_video
    spawn('QUEUE=oneoff bundle exec rails jobs:workoff')
    redirect_back fallback_location: resource_path, notice: 'Video is being archived'
  end

  collection_action :sync, method: :get do
    VideoSyncJob.perform_later
    redirect_to videos_path, notice: 'Syncing videos...'
  end

  collection_action :delete_all, method: :get do
    Video.delete_all
    ChannelQueueItem.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('videos')
    redirect_to videos_path, notice: 'Videos Deleted'
  end

  index do
    column 'ID', :id
    column 'API ID', :api_id
    column :name
    column :deck
    column :show
    column 'Duration', sortable: :length do |video|
      video.length_str
    end
    column :premium
    column :publish_date
    column :error_on_last_play
    column :archived
    column :archived_quality do |video|
      status_tag(video.archived_quality, class: video.archived_quality) if video.archived
    end
    actions do |video|
      item 'Archive', archive_video_path(video), method: :put
    end
  end

  show do |v|
    default_main_content
    panel "Player" do
      video id: 'video-player', class: 'video-js', type: 'video/mp4' do
        source src: v.get_url, type: 'video/mp4'
      end
    end
  end

  filter :name
  filter :deck
  filter :show, collection: proc { Show.all.order(title: :asc).pluck(:title, :api_id) }
  filter :premium
  filter :publish_date
  filter :error_on_last_play
  filter :length, label: 'Length (seconds)'
  filter :archived
  filter :archived_quality, as: :select, collection: %w[hd high low]
end

