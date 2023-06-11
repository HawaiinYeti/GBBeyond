ActiveAdmin.register Video do
  menu priority: 4

  actions :all, except: [:new, :edit, :destroy]

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
  filter :show
  filter :show
  filter :publish_date
  filter :error_on_last_play
  filter :length, label: 'Length (seconds)'
end
