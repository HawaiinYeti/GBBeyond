import consumer from "channels/consumer"

$(window).on('load', function() {
  $('body.dashboard.index').each(function() {
    $('#title_bar').hide()
    consumer.subscriptions.create("ChannelsChannel", {
      connected() {
        // Called when the subscription is ready for use on the server
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
      },

      received(data) {
        // Called when there's incoming data on the websocket for this channel
        if (data.command == 'channel_update') {
          var key = parseInt(Object.keys(data.data)[0])
          channels[key] = data.data[key]
          if (current_channel == key &&
              (window.waiting_on_channel_update ||
               (channels[key].queue.length == 0 || Date.parse(channels[key].queue[0].queue_item.finish_time) < Date.now()))) {
            playChannel(current_channel)
          }
          updateChannelListings()
        }
      }
    });

    window.current_channel = parseInt($('#channel-listing .channel').first().data('channel-id'))

    function initPlay() {
      var first_key = Object.keys(channels)[0]
      if (channels[first_key].queue.length > 0) {
        playChannel(first_key)
      }
    }

    function playChannel(key) {
      current_channel = parseInt(key)
      var channel_el = $(`#channel-listing .channel[data-channel-id=${key}]`)
      $('#channel-listing .channel').removeClass('playing')
      channel_el.addClass('playing')

      if (channels[key].queue.length > 0) {
        player.src({ type: 'video/mp4', src: buildUrl(channels[key].queue[0]) })

        updateWhatsPlaying(channels[key].queue[0])
      } else {
        player.pause()
      }
    }

    function updateQueues() {
      Object.entries(channels).forEach(entry => {
        const [id, channel] = entry;
        if (channel.queue[0] && Date.parse(channel.queue[0].queue_item.finish_time) < Date.now()) {
          channel.queue.shift()
          updateChannelListings()
        }
      })
    }

    function updateChannelListings() {
      Object.entries(channels).forEach(entry => {
        const [id, channel] = entry;
        if (channel.queue.length > 0) {
          var channel_el = $(`#channel-listing .channel[data-channel-id=${id}]`)
          var video = channel.queue[0].video
          if (channel_el.find('.channel-video').html() != video.name) {
            channel_el.find('.channel-video').html(video.name)
            channel_el.find('.channel-thumbnail img').attr('src', video.image_urls.original_url)
          }
        } else {
          var channel_el = $(`#channel-listing .channel[data-channel-id=${id}]`)
          channel_el.find('.channel-video').html('')
          channel_el.find('.channel-thumbnail img').attr('src', '')
        }
      })
    }

    function updateWhatsPlaying(queue_item) {
      var video = queue_item.video
      $('#current-video-panel #current-video-name h3').html(video.name)
      $('#current-video-panel #current-video-deck p').html(video.deck)
      $('#current-video-panel #current-video-thumbnail img').attr('src', video.image_urls.original_url)
      $('#current-video-panel #current-video-publish-date span').html(moment(video.publish_date).format("YYYY-MM-DD"))
      $('#current-video-panel #current-video-start-time span').html(moment(queue_item.queue_item.start_time).format("YYYY-MM-DD HH:mm:ss"))
      $('#current-video-panel #current-video-finish-time span').html(moment(queue_item.queue_item.finish_time).format("YYYY-MM-DD HH:mm:ss"))
      $('#current-video-panel #current-video-skip-button a').attr('href', queue_item.skip_url)
    }

    function buildUrl(data) {
      var seconds_since_start = Math.floor((Date.now() - Date.parse(data.queue_item.start_time)) / 1000);
      return `${data.url}#t=${seconds_since_start}`
    }

    player = videojs('video-player', {
      autoplay: 'any',
      fluid: true,
      controls: true,
      preload: 'auto',
      userActions: {
        click: false
      },
      controlBar: {
        playToggle: false
      }
    })
    player.controlBar.progressControl.disable()

    player.on('ended', function() {
      updateQueues()
      playChannel(current_channel)
    })

    player.on('contextmenu', function(e) {
      e.preventDefault()
    })

    $('video').on('error', function(e) {
      if (e.target.error.code == 4) {
        $.ajax({
          url: '/player_error',
          method: 'POST',
          data: {
            channel_id: current_channel,
            video_id: channels[current_channel].queue[0].video.id,
            queue_item_id: channels[current_channel].queue[0].queue_item.id
          },
          success: function(data) {
            channels[current_channel] = data.data[current_channel]
            playChannel(current_channel)
          }
        })
      }
    })

    $('#channel-listing .channel').on('click', function() {
      playChannel($(this).data('channel-id'))
    })

    $('#current-video-panel #current-video-skip-button a').on('click', function(e) {
      window.waiting_on_channel_update = true
    })

    setInterval(function() {
      updateQueues()
    } , 1000)
    initPlay()
  })
})
