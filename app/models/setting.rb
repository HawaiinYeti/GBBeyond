class Setting < RailsSettings::Base
  cache_prefix { "v1" }
  after_create :sync_video_on_first_save, :add_archive_path_to_env
  after_update :sync_video_on_first_save, :add_archive_path_to_env

  field :gb_api_key, type: :string, default: ''
  field :premium, type: :boolean, default: true
  field :play_jwplayer, type: :boolean, default: false
  field :quality_play_order, type: :string, default: 'hd,high,low'
  field :archive_path, type: :string, default: ''

  def sync_video_on_first_save
    if self.var == 'gb_api_key' && (saved_change_to_value?(from: nil) || Video.all.size.zero?)
      VideoSyncJob.perform_later(nil)
    end
  end

  def add_archive_path_to_env
    if var == 'archive_path' && saved_change_to_value?
      env_file = Rails.root.join('.env')
      if File.exist?(env_file)
        env = File.read(env_file)
        if env.match(/^ARCHIVE_PATH=/)
          env.gsub!(/^ARCHIVE_PATH=.*/, "ARCHIVE_PATH=#{Setting.archive_path}")
        else
          env += "\nARCHIVE_PATH=#{Setting.archive_path}"
        end
        File.write(env_file, env)
      else
        File.write(env_file, "ARCHIVE_PATH=#{Setting.archive_path}")
      end
    end
  end
end
