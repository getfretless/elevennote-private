$(document).ready(function() {
  $('#notes li').click(function(ev) {
    ev.preventDefault();
    location.href = $(ev.target).closest('li').data('url');
  });
  $('.bootsy_text_area').height($(window).height() - 210);
  $(window).resize(function() {
    $('.bootsy_text_area').height($(window).height() - 210);
  });
});
