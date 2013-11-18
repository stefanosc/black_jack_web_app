$(document).ready(function() {

  player_hits();
  player_stays();
  dealer_hits();

});


function player_hits() {
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
}

function player_stays() {
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
}

function dealer_hits() {
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
}