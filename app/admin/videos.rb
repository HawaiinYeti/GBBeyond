ActiveAdmin.register Video do
  menu priority: 4

  actions :all, except: [:new, :edit, :destroy]

  action_item only: :index do
    running = Delayed::Job.where("handler LIKE '%VideoSyncJob%'").size.positive?

    link_to 'Sync Videos', sync_videos_path,
            class: (running ? 'disabled' : ''),
            title: (running ? 'Job is currently running' : '')
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
    actions
  end

  filter :name
  filter :show, collection: proc { Show.all.order(title: :asc).pluck(:title, :api_id) }
  filter :publish_date
  filter :error_on_last_play
  filter :length, label: 'Length (seconds)'
end
