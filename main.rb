require 'rubygems'
require 'sinatra'
require "pry"

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17

helpers do 
  def card_to_card_img card

    case card[1]
    when "C"
      suit = "clubs_"
    when "D"
      suit = "diamonds_"
    when "H"
      suit = "hearts_"
    when "S"
      suit = "spades_"      
    end

    case card[0]
    when "A"
      face_value = "ace"
    when "J"
      face_value = "jack"
    when "Q"
      face_value = "queen"
    when "K" 
      face_value = "king"
    else
      face_value = card[0]
    end

    suit + face_value + ".jpg"    
  end

  def deal
    session[:deck].pop
  end

  def total cards
    
    values = cards.map{|card| card[0] }
    total = 0
    
    values.each do |v|
      if v == 'A'
        total += 11
      else  
        total += v.to_i == 0 ? 10 : v.to_i
      end
    end
    
    # correct for aces
    values.select{|card| card == "A"}.count.times do
      break if total <= BLACKJACK_AMOUNT
      total -= 10
    end  
    total
  end


  def busted? cards
    (total(cards)) > BLACKJACK_AMOUNT
  end

  def has_blackjack? cards
    if cards.length == 2 and (total(cards)) == BLACKJACK_AMOUNT
      true
    else
      false
    end
  end

  def win(msg)
    session[:turn] = "game_over"
    @success = "<b>#{session[:player_name]} you won this hand.</b> <br>#{msg}"
  end

  def lost(msg)
    session[:turn] = "game_over"
    @error = "<b>#{session[:player_name]} you lost this hand.</b><br> #{msg}"
  end

  def push(msg)
    session[:turn] = "game_over"
    @success = "<b>#{session[:player_name]} this hand is a \"push\".</b> <br>#{msg}"
  end
  
end

# before do


# end




get '/' do

    erb :home

end


get '/new-game' do
  session[:turn] = "new"
  erb :'new-game'
end


post '/set_player_name' do
  if params[:player_name].empty?
    @error = "You can't leave the name empty, please choose a name and click Play"
    erb :'new-game'
  else
  session[:player_name] = params[:player_name]
  session[:player_money] = 500
  redirect '/bet'
  end
end


get '/bet' do
  session[:turn] = "new"
  if session[:player_money] < 1
    @error = "I am sorry you finished your money. You can start a new game if you like"
    erb :'new-game'
  else
    erb :bet
  end
end

post '/:player_name/bet' do
  session[:player_bet] = params[:player_bet].to_i
  if session[:player_bet] == 0
    @error = "The minimum bet is $1 please bet and click Play"
    erb :bet
  elsif session[:player_bet] > session[:player_money]
    @error = "You can't bet more than what you have, please only be up to $#{session[:player_money]}"
    erb :bet
  else
    session[:player_money] -= session[:player_bet]
    redirect "/game"
  end
end


get '/game' do 
  suits = [ 'H', 'D', 'C', 'S' ]
  values = [ '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A' ]

  session[:deck] = (values.product(suits)).shuffle!
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:turn] = "player"
  session[:stay_msg] = nil

  session[:player_cards] << deal
  session[:dealer_cards] << deal
  session[:player_cards] << deal
  session[:dealer_cards] << deal
  if has_blackjack?(session[:player_cards]) and !has_blackjack?(session[:dealer_cards])
    session[:player_money] += (session[:player_bet]*2.5)
    win("You hit BlackJack. Your balance is #{session[:player_money]}")
  end
  erb :first_game
end

post '/game/player/hit' do
  # binding.pry
  session[:player_cards] << deal
  if total(session[:player_cards]) > BLACKJACK_AMOUNT
    lost("You busted with #{total(session[:player_cards])}. Your new balance is #{session[:player_money]}")
    session[:stay_msg] = "Unfortunately you busted"
  end
  erb :game, :layout => false
end

post '/game/player/stay' do
  # binding.pry
  session[:stay_msg] = "#{session[:player_name]}, you decided to stay with #{total(session[:player_cards])}"
  session[:turn] = "dealer"
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  if has_blackjack?(session[:dealer_cards])
    lost("The dealer hit BlackJack. Your balance is #{session[:player_money]}")
    session[:turn] = "game_over"
  elsif total(session[:dealer_cards]) > BLACKJACK_AMOUNT
    session[:player_money] += (session[:player_bet]*2)
    win("The dealer busted. Your balance is #{session[:player_money]}")
    session[:turn] = "game_over"
  elsif total(session[:dealer_cards]) >= DEALER_MIN_HIT
    redirect '/game/compare'
  else
    session[:turn] = "dealer"
  end
     
  erb :game, :layout => false

end

post '/game/dealer/hit' do
  session[:dealer_cards] << deal
  redirect '/game/dealer'
end

get '/game/compare' do
  player_total = total(session[:player_cards])
  dealer_total = total(session[:dealer_cards])
  if dealer_total > player_total
    lost("You stayed with #{player_total}. The dealer stayed with #{dealer_total}. Your balance is #{session[:player_money]}")
    session[:turn] = "game_over"
    erb :game, :layout => false
  elsif dealer_total = player_total
    session[:player_money] += (session[:player_bet])
    push("You stayed with #{player_total}. The dealer stayed with #{dealer_total}. Your balance is #{session[:player_money]}")
    session[:turn] = "game_over"
    erb :game, :layout => false
  else
    session[:player_money] += (session[:player_bet]*2)
    win("You stayed with #{player_total}. The dealer stayed with #{dealer_total}. Your new balance is #{session[:player_money]}")
    session[:turn] = "game_over"
    erb :game, :layout => false
  end

end