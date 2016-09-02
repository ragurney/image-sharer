$(document).on('ajax:success', '.js-delete-image', function(event, data) {
  $("[data-image-id='" + data.image_id + "']").remove();
});
