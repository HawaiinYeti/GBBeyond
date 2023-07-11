ActiveAdmin.register Channel do
  menu priority: 2
  filter :name
  form partial: 'form'
  config.sort_order = 'position_asc'


  controller do
    def model_params
      params.require(:channel).permit(:name, :position, :archive_videos)
    end

    def update
      channel = Channel.find(params[:id])
      channel.update(model_params)
      channel.update(q: JSON.parse((params[:channel][:q] || '{}').to_s.gsub('=>', ':')))
      redirect_to channels_path
    end

    def create
      channel = Channel.create(model_params)
      channel.update(q: JSON.parse((params[:channel][:q] || '{}').to_s.gsub('=>', ':')))
      redirect_to channels_path
    end
  end

  member_action :skip_queue_item, method: :post do
    queue_item = resource.channel_queue_items.find(params[:queue_item_id])
    queue_item.skip
    redirect_back fallback_location: resource_path, notice: "\"#{queue_item.video.name}\" has been skipped"
  end

  index download_links: false do
    column :position
    column :name
    column 'Current Video' do |channel|
      link_to channel.current_queue_item&.video&.name, channel.current_queue_item&.video
    end
    column 'Total Videos' do |channel|
      channel.videos.size
    end
    column 'Total Duration' do |channel|
      # convert to hours, formatted in hours:minues:seconds
      channel.videos.length_str
    end
    column :archive_videos
    actions
  end

  show do
    default_main_content
    panel "Current Queue" do
      paginated_collection(channel.channel_queue_items.eager_load(:video).page(params[:page]).per(50).order(start_time: :asc), download_links: false) do
        table_for collection do |queue_item|
          column 'Name' do |q_i|
            link_to q_i.video.name, q_i.video
          end
          column :start_time
          column 'Duration' do |q_i|
            q_i.video.length_str
          end
          column 'Show' do |q_i|
            q_i.video.show&.title
          end
          column 'Actions' do |q_i|
            link_to 'Skip',  skip_queue_item_channel_path(q_i.channel.id, queue_item_id: q_i.id), method: :post
          end
        end
      end
    end

    panel "Videos" do
      order = params[:order]&.gsub('_asc', ' asc')&.gsub('_desc', ' desc') || 'publish_date desc'
      paginated_collection(channel.videos.eager_load(:show).page(params[:page]).per(50).order(order), download_links: false) do
        table_for collection, sortable: true do |video|
          column :name, sortable: :name
          column :publish_date, sortable: :publish_date
          column 'Duration', sortable: :length do |video|
            video.length_str
          end
          column 'Show' do |video|
            video.show&.title
          end

        end
      end
    end
  end

end
