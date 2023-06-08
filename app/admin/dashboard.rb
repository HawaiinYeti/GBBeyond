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
            panel 'Channels', id: 'channel-listing-panel' do
              div id: 'channel-listing' do
                Channel.all.each do |channel|
                  div class: 'channel', 'data-channel-id': channel.id do
                    div class: 'channel-thumbnail' do
                      img src: channel.current_queue_item.video.image_urls['original_url']
                    end
                    div do
                      div class: 'channel-name' do
                        channel.name
                      end
                      div class: 'channel-video' do
                        channel.current_queue_item.video.name
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
    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
