class Setting < RailsSettings::Base
  cache_prefix { "v1" }
  after_create :sync_video_on_first_save
  after_update :sync_video_on_first_save

  field :gb_api_key, type: :string, default: ''
  field :premium, type: :boolean, default: true
  field :play_jwplayer, type: :boolean, default: false
  field :quality_play_order, type: :string, default: 'hd,high,low'

  def sync_video_on_first_save
    if self.var == 'gb_api_key' && (saved_change_to_value?(from: nil) || Video.all.size.zero?)
      VideoSyncJob.perform_later(nil)
    end
  end
end
