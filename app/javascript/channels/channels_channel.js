import consumer from "channels/consumer"

$(window).on('load', function() {
  $('#title_bar').hide()
  $('body.dashboard.index').each(function() {
    consumer.subscriptions.create("ChannelsChannel", {
      connected() {
        // Called when the subscription is ready for use on the server
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
      },

      received(data) {
        // Called when there's incoming data on the websocket for this channel
        if (data.command == "initial_channel_listing") {
          channels = data.data
          playChannel(Object.keys(channels)[0])
        } else if (data.command == 'channel_update') {
          channels[Object.keys(data.data)[0]] = data.data
        }
      }
    });

    var current_channel = {}
    window.channels = []

    function playChannel(key) {
      var channel_el = $(`#channel-listing .channel[data-channel-id=${key}]`)
      channel_el.addClass('playing')

      player.src(buildUrl(channels[key].queue[0]))
      current_channel = key
    }

    function updateQueues() {
      Object.entries(channels).forEach(entry => {
        const [id, channel] = entry;
        if (Date.parse(channel.queue[0].queue_item.finish_time) < Date.now()) {
          channel.queue.shift()
          updateChannelListings()
        }
      })
    }

    function updateChannelListings() {
      Object.entries(channels).forEach(entry => {
        const [id, channel] = entry;
        var channel_el = $(`#channel-listing .channel[data-channel-id=${id}]`)
        var video = channel.queue[0].video
        if (channel_el.find('.channel-video').html() != video.name) {
          channel_el.find('.channel-video').html(video.name)
          channel_el.find('.channel-thumbnail img').attr('src', video.image_urls.original_url)
        }
      })
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
    $('#channel-listing .channel').on('click', function() {
      playChannel($(this).data('channel-id'))
      $('#channel-listing .channel').removeClass('playing')
      $(this).addClass('playing')
    })

    setInterval(function() {
      updateQueues()
    } , 1000)
  })
})
