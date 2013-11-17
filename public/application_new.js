$(document).ready(function() {
  // body...
  $(document).on('click', '#hit_button', function() {
    // body...
    $.ajax({
      url: '/game/player/hit',
      type: 'POST',
    })
    .done(function(response) {
      $("#game-wrapper").replaceWith(response);
    });
    
    return false;
  });

  $(document).on('click', '#stay_button', function() {
    // body...
    $.ajax({
      url: '/game/player/stay',
      type: 'POST',
    })
    .done(function(response) {
      $("#game-wrapper").replaceWith(response);
    });
    
    return false;
  });

  $(document).on('click', '#dealer_hit', function() {
    // body...
    $.ajax({
      url: '/game/dealer/hit',
      type: 'POST',
    })
    .done(function(response) {
      $("#game-wrapper").replaceWith(response);
    });
    
    return false;
  });


});