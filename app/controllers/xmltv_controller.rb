class XmltvController < ApplicationController
  def index
    @channels = Channel.all
    respond_to do |format|
      format.xml { render xml: build_xml.to_xml }
    end
  end

  private

  def build_xml
    Nokogiri::XML::Builder.new do |xml|
      xml.tv('generator-info-name': 'GBBeyond') {
        Channel.all.order(id: :asc).each do |channel|
          xml.channel(id: channel.id) {
            xml.display_name channel.name
          }
        end
        ChannelQueueItem.all.order(id: :asc).each do |channel_queue_item|
          xml.programme(
            start: channel_queue_item.start_time.strftime('%Y%m%d%H%M%S %z'),
            stop: channel_queue_item.finish_time.strftime('%Y%m%d%H%M%S %z'),
            channel: channel_queue_item.channel_id
          ) {
            xml.title(channel_queue_item.video.show.title, lang: 'en') if channel_queue_item.video.show.present?
            xml.send('sub-title', channel_queue_item.video.name, lang: 'en')
            xml.previously_shown start: channel_queue_item.video.publish_date.strftime('%Y%m%d%H%M%S %z')
            xml.desc channel_queue_item.video.deck, lang: 'en'
            xml.icon src: channel_queue_item.video.image_urls['original_url']
          }
        end
      }
    end
  end
end
