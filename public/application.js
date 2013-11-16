$(document).ready(function() {
  // body...
  $("#hit_button").click(function() {
    // body...
    $.ajax({
      url: '/game/player/hit',
      type: 'POST',
    })
    .done(function(msg) {
      console.log("msg");
    });
    
    return false;
  });
});