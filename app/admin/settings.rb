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

  action_item only: :index do
    link_to 'Delete All Videos', delete_all_videos_path, 'data-confirm': 'This will permanently delete all videos, and you will have to re-sync videos. Are you sure?', method: :get
  end

  content do
    form for: Setting.new, action: settings_update_path, method: :post do |f|
      columns do
        panel 'Giant Bomb' do
          f.input :authenticity_token, type: :hidden, name: :authenticity_token, value: form_authenticity_token
          ol do
            settings.each do |key, h|
              li do
                f.label h[:name], for: "setting[#{key}]"

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
  end
end

def model_params
  params.require(:setting).permit(*settings.symbolize_keys.keys)
end

def settings
  {
    'gb_api_key' => {name: 'Giant Bomb API Key', field_type: :text},
    'premium' => {name: 'Premium', field_type: :checkbox},
    'play_jwplayer' => {name: 'Play JW Player Videos', field_type: :checkbox},
    'quality_play_order' => {name: 'Quality Play Order', field_type: :text},
  }
end