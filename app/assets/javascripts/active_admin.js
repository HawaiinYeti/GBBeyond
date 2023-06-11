//= require active_admin/base
//= require moment

$('#channel-video-filters .add_fields').off('click')
$(window).on('load', function() {

  $('body').attr('data-turbo', 'false')
  $('body.channels.edit, body.channels.new').each(function() {
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
        regexp = new RegExp('new_channel', 'g');
        button.before(content.replace(regexp, new_id));
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
        content = String(content).replaceAll(name, name + '[g][' + new_id + ']');
        button.before(content);
        initAddButtons()
        initRemoveButtons()
        initNestButtons()
      })
    }
    initNestButtons()
  })
})
