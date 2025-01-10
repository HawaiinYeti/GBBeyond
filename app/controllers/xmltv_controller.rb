class XmltvController < ApplicationController
  include ActionController::Live

  def index
    respond_to do |format|
      format.xml { render xml: build_xml.to_xml }
    end
  end

  def discover
    respond_to do |format|
      format.json { render json: build_discover }
    end
  end

  def lineup_status
    respond_to do |format|
      format.json { render json: { ScanInProgress: false, ScanPossible: true, Source: 'Cable' } }
    end
  end

  def lineup
    respond_to do |format|
      format.json { render json: build_lineup }
    end
  end

  def channel
    channel = Channel.find_by(position: params[:id])
    original_url_without_extension = request.original_url.chomp(File.extname(request.original_url))

    respond_to do |format|
      format.text do

        render plain: "ffconcat version 1.0\nfile #{channel.queue_item_at(5.seconds.since).video.get_url}\ninpoint #{[channel.current_queue_item.current_time - 5, 0].max}\n\nfile #{original_url_without_extension}\noption safe 0"
      end
      format.all do
        queue_item = channel.current_queue_item
        url = queue_item.video.get_url

        ffmpeg_command = "ffmpeg -nostdin -re -protocol_whitelist file,http,https,tls,tcp -safe 0 -i '#{original_url_without_extension}.txt' -muxdelay 1 -muxpreload 1 -c:v copy -c:a copy -f mpegts -movflags frag_keyframe+empty_moov pipe:1"

        send_stream(filename: 'test', disposition: 'attachment') do |stream|
          IO.popen(ffmpeg_command, 'rb') do |io|
            while (buffer = io.read(4096))
              response.stream.write(buffer)
            end
          end
        rescue
          response.stream.close
        ensure
          response.stream.close
        end
      end
    end
  end

  def epg
    render json: Channel.channel_listing
  end

  private

  def build_xml
    Nokogiri::XML::Builder.new do |xml|
      xml.tv('generator-info-name': 'GBBeyond') {
        Channel.all.order(position: :asc).each do |channel|
          xml.channel(id: channel.position) {
            xml.send('display-name', channel.name)
          }
        end
        ChannelQueueItem.eager_load(:channel, {video: [:show]}).all.order(position: :asc).each do |channel_queue_item|
          xml.programme(
            start: channel_queue_item.start_time.strftime('%Y%m%d%H%M%S %z'),
            stop: channel_queue_item.finish_time.strftime('%Y%m%d%H%M%S %z'),
            channel: channel_queue_item.channel.position
          ) {
            xml.send('sub-title', channel_queue_item.video.show.title, lang: 'en') if channel_queue_item.video.show.present?
            xml.title channel_queue_item.video.name, lang: 'en'
            xml.previously_shown start: channel_queue_item.video.publish_date.strftime('%Y%m%d%H%M%S %z')
            xml.desc channel_queue_item.video.deck, lang: 'en'
            xml.icon src: channel_queue_item.video.image_urls['original_url']
          }
        end
      }
    end
  end

  def build_discover
    {
      FriendlyName: 'GBBeyond',
      Manufacturer: 'GBBeyond - HawaiinYeti',
      ModelNumber: 'HDTC-2US',
      BaseURL: "http://#{request.host_with_port}",
      LineupURL: "http://#{request.host_with_port}/xmltv/lineup.json"
    }
  end

  def build_lineup
    Channel.all.order(position: :asc).map do |channel|
      {
        GuideNumber: channel.position.to_s,
        GuideName: channel.name,
        URL: "http://#{request.host_with_port}/xmltv/channel/#{channel.position}.mp4"
      }
    end
  end
end
