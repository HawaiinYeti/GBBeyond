ActiveAdmin.register Channel do
  menu priority: 2
  filter :name
  form partial: 'form'


  controller do
    def model_params
      params.require(:channel).permit(:name)
    end

    def update
      channel = Channel.find(params[:id])
      channel.update(model_params)
      channel.update(q: params[:q])
      redirect_to channels_path
    end

    def create
      channel = Channel.create(model_params)
      channel.update(q: params[:q])
      redirect_to channels_path
    end
  end

  index download_links: false do
    column :id
    column :name
    column 'Total Videos' do |channel|
      channel.videos.size
    end
    column 'Total Duration' do |channel|
      # convert to hours, formatted in hours:minues:seconds
      channel.videos.length_str
    end
    actions
  end

  show do
    default_main_content
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
