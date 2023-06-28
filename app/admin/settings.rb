ActiveAdmin.register_page "Settings" do
  menu priority: 5

  page_action :update, method: :post do
    model_params.keys.each do |key|
      next if model_params[key].nil?

      setting = Setting.new(var: key)
      setting.value = model_params[key].strip
      unless setting.valid?
        @errors.merge!(setting.errors)
      end
    end

    model_params.keys.each do |key|
      Setting.send("#{key}=", model_params[key].strip) unless model_params[key].nil?
    end

    redirect_to '/settings', notice: "Settings were successfully updated."
  end

  page_action :set_api_key, method: :post do
    if params[:token] == 'reset'
      Setting.gb_api_key = nil
    else
      resp = HTTParty.get("http://www.giantbomb.com/app/gbbeyond/get-result?regCode=#{params[:token]}&format=json").parsed_response
      Setting.gb_api_key = resp['regToken']
    end
    redirect_to '/settings', notice: "API Key was successfully updated."
  end

  action_item only: :index do
    link_to 'Delete All Videos', delete_all_videos_path, 'data-confirm': 'This will permanently delete all videos, and you will have to re-sync videos. Are you sure?', method: :get
  end

  content do
    panel 'Giant Bomb API Key' do
      if Setting.gb_api_key.present?
        h3 'Giant Bomb API Key'
        para "#{"*" * 36}#{Setting.gb_api_key[-4..-1]}"

        form action: settings_set_api_key_path, method: :post do |f|
          f.input :authenticity_token, type: :hidden, name: :authenticity_token, value: form_authenticity_token
          f.input :token, type: :hidden, name: :token, value: 'reset'
          f.input :submit, type: :submit, value: 'Reset'
        end
      else
        h3 'How to get a Giant Bomb API key:'
        ol do
          li do
            para "Go #{link_to 'here', 'https://www.giantbomb.com/app/gbbeyond/', target: '_blank'} and copy the code.".html_safe
          end
          li do
            para 'Enter code:'
            form action: settings_set_api_key_path, method: :post do |f|
              f.input :authenticity_token, type: :hidden, name: :authenticity_token, value: form_authenticity_token
              f.input :token, type: :text, name: :token
              br
              f.input :submit, type: :submit, value: 'Save'
            end
          end
        end
      end
    end

    form for: Setting.new, action: settings_update_path, method: :post do |f|
      columns do
        panel 'Giant Bomb' do
          f.input :authenticity_token, type: :hidden, name: :authenticity_token, value: form_authenticity_token
          ol do
            settings.each do |key, h|
              li do
                f.label h[:name], for: "setting[#{key}]"
                f.status_tag '?', class: 'status_tag', title: h[:description] if h[:description].present?

                if h[:field_type] == :checkbox
                  f.input key, { type: :hidden, name: "setting[#{key}]", id: "setting_#{key}", value: '0' }
                end
                f.input key, { type: h[:field_type], value: Setting.send(key), name: "setting[#{key}]", id: "setting_#{key}" }.merge(({checked: (Setting.send(key) ? 'checked' : ''), value: '1' } if h[:field_type] == :checkbox).to_h)
              end
            end
          end
        end
      f.input :submit, type: :submit, value: 'Save'
      end
    end

    panel 'TV Tuner Info' do
      h3 'HDHomeRun Device Address:'
      para link_to(request.base_url + '/xmltv', request.base_url + '/xmltv')
      h3 'xmltv.xml location:'
      para link_to(request.base_url + '/xmltv.xml', request.base_url + '/xmltv.xml')
    end
  end
end

def model_params
  params.require(:setting).permit(*settings.symbolize_keys.keys)
end

def settings
  {
    'premium' => { name: 'Premium', field_type: :checkbox, description: 'Allow premium videos to be played.' },
    'play_jwplayer' => { name: 'Play JW Player Videos', field_type: :checkbox, description: 'Allow playing videos with JWPlayer URLs. Starting ~2023-02-01, GB started using the JWPlayer CDN. The JWPlayer URLs provided have short expiry times, requiring the API to be hit every time the video is queued up on order to get a new URL. If you have a lot of channels, this can result in you hitting the hourly API limit. Leaving this setting disabled will prevent new videos from being added to your channel queues.' },
    'quality_play_order' => { name: 'Quality Play Order', field_type: :text, description: 'Comma separated list of qualities to play in order of preference. Example: "hd,high,low"' },
    'archive_path' => { name: 'Archive Path', field_type: :text, description: 'Local directory to archive videos to. Example: "/Users/user_name/media/gb_videos" or "C:\media\gb_videos". You also need to enable the Archive Videos setting on individual channels for videos to save. Docker restart and rebuild required for changes to take effect. Quick restart with `. ./restart.sh` in terminal' },
  }
end