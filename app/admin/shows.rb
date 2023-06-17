ActiveAdmin.register Show do
  menu priority: 3

  filter :title
  index download_links: false do
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

  show do
    default_main_content
    panel "Videos" do
      order = params[:order]&.gsub('_asc', ' asc')&.gsub('_desc', ' desc') || 'publish_date desc'
      paginated_collection(show.videos.eager_load(:show).page(params[:page]).per(50).order(order), download_links: false) do
        table_for collection, sortable: true do |video|
          column :name, sortable: :name
          column :publish_date, sortable: :publish_date
          column 'Duration', sortable: :length do |video|
            video.length_str
          end
        end
      end
    end
  end

end
