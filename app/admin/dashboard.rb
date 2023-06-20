# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content do
    tabs do
      tab :player do
        columns do
          column span: 3 do
            panel '', id: 'video-player-panel' do
              video id: 'video-player', class: 'video-js' do
                source src: 'blank.mp4', type: 'video/mp4'
              end
            end
          end
          column do
            panel "What's Playing", id: 'current-video-panel'  do
              div id: 'current-video' do
                div id: 'current-video-thumbnail' do
                  img src: ''
                end
                div id: 'current-video-name' do
                  tag.h3
                end
                div id: 'current-video-deck' do
                  tag.p
                end
                div id: 'current-video-publish-date' do
                  ('<b>Aired:</b> ' + tag.span).html_safe
                end
                div id: 'current-video-start-time' do
                  ('<b>Started:</b> ' + tag.span).html_safe
                end
                div id: 'current-video-finish-time' do
                  ('<b>Ends:</b> ' + tag.span).html_safe
                end
              end
            end
            panel 'Channels', id: 'channel-listing-panel' do
              div id: 'channel-listing' do
                Channel.all.order(position: :asc).each do |channel|
                  div class: 'channel', 'data-channel-id': channel.id do
                    div class: 'channel-thumbnail' do
                      img src: (channel.current_queue_item&.video&.image_urls || {}).dig('original_url')
                    end
                    div do
                      div class: 'channel-name' do
                        channel.name
                      end
                      div class: 'channel-video' do
                        channel.current_queue_item&.video&.name
                      end
                    end
                  end
                end
              end
            end

          end
        end
      end
      tab :guide do

      end
    end
  end
end
