ActiveAdmin.register Show do
  menu priority: 3

  filter :title
  index do
    column :id
    column :title
    column :total_videos do |show|
      show.videos.size
    end
    column :total_duration do |show|
      show.videos.length_str
    end
    actions
  end
end
