//= require active_admin/base
//= require moment

$('#channel-video-filters .add_fields').off('click')
$(window).on('load', function() {

  $('body').attr('data-turbo', 'false')
  $('body.channels.edit, body.channels.new').each(function() {
    $('.ui-tab').on('click', function(e) {
      $('.tab-content input, .tab-content select').attr('disabled', 'disabled').attr('readonly', 'readonly')
      $(e.target.hash).find('input, select').removeAttr('disabled').removeAttr('readonly')
    })

    $('.video-filters input, .video-filters select').each(function() {
      var name = $(this).attr('name')
    })

    function initRemoveButtons() {
      $('.remove_fields').off('click').on('click', function(e) {
        e.preventDefault();
        $(this).closest('.video-filters, .fields').remove()
        initRemoveButtons()
      })
    }
    initRemoveButtons()

    function initAddButtons() {
      $('.add_fields').off('click').on('click', function(e) {
        e.preventDefault();
        var button = $(this)
        var content = $(button).data('content')
        var new_id, regexp;
        new_id = new Date().getTime();

        content = content.replaceAll('new_condition', new_id).replaceAll('new_grouping', new_id).replaceAll('new_channel', new_id).replaceAll('"q', '"channel[q]')
        button.before(content);
        initAddButtons()
        initRemoveButtons()
        initNestButtons()
      })
    }
    initAddButtons()

    function initNestButtons() {
      $('.nest_fields').off('click').on('click', function(e) {
        e.preventDefault();
        var button = $(this)
        var content = $(button).closest('.inputs').clone().find('.condition').remove().end().prop('outerHTML')
        var new_id = new Date().getTime();
        var name = $(button).closest('.inputs').data('object-name')

        content = content.replaceAll(name, name + '[g][' + new_id + ']').replaceAll('new_condition', new_id).replaceAll('new_grouping', new_id).replaceAll('new_channel', new_id).replaceAll('"q', '"channel[q]')
        button.before(content);
        initAddButtons()
        initRemoveButtons()
        initNestButtons()
      })
    }
    initNestButtons()
  })

  $('body.videos.show').each(function() {
    videojs('video-player', {
      autoplay: 'any',
      fluid: true,
      controls: true,
      preload: 'auto'
    })
  })
})
