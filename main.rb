require 'rubygems'
require 'sinatra'
require "pry"

set :sessions, true

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
      break if total <= 21
      total -= 10
    end  
    total
  end


  def busted? cards
    (total(cards)) > 21
  end

  def has_blackjack? cards
    if cards.length == 2 and (total(cards)) == 21
      true
    else
      false
    end
  end

  def player_turn

    
  end
  
end

before do
  @show_hit_stay_btn = true

end




get '/' do
  # if session[:player_name]
  #   redirect '/new-game'
  # else
    erb :home
  # end
end


get '/new-game' do
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

  session[:player_cards] << deal
  session[:dealer_cards] << deal
  session[:player_cards] << deal
  session[:dealer_cards] << deal
  if has_blackjack?(session[:player_cards])
    session[:player_money] += (session[:player_bet]*3)
    @success = "#{session[:player_name]}, you hit BlackJack, you won this hand. Your balance is #{session[:player_money]}"
    @show_hit_stay_btn = false
    session[:dealer_hit] = false
    @play_again = true
  end
  erb :game
end

post '/:player_name/hit' do
  # binding.pry
  session[:player_cards] << deal
  if total(session[:player_cards]) > 21
    @error = "Sorry #{session[:player_name]}, you busted with #{total(session[:player_cards])}. You lost this hand. Your new balance is #{session[:player_money]}"
    @play_again = true
    @show_hit_stay_btn = false
    session[:dealer_hit] = false

  end
  erb :game
end

post '/:player_name/stay' do
  # binding.pry
  @success = "#{session[:player_name]}, you decided to stay with #{total(session[:player_cards])}"
  @show_hit_stay_btn = false
  session[:dealer_hit] = true
  redirect '/game/dealer'
end

get '/game/dealer' do
  @show_hit_stay_btn = false
  if has_blackjack?(session[:dealer_cards])
    @error = "Sorry #{session[:player_name]}, the dealer hit BlackJack, you loose this hand! Your balance is #{session[:player_money]}"
    session[:dealer_hit] = false
    @play_again = true
  elsif total(session[:dealer_cards]) > 21
    session[:player_money] += (session[:player_bet]*2)
    @success = "#{session[:player_name]}, the dealer busted, you won this game! Your balance is #{session[:player_money]}"
    session[:dealer_hit] = false
    @play_again = true
  elsif total(session[:dealer_cards]) >= 17
    redirect '/game/compare'
  else
    session[:dealer_hit] = true
  end
     
  erb :game 
    
end

post '/game/dealer/hit' do
  session[:dealer_cards] << deal
  redirect '/game/dealer'
end

get '/game/compare' do
  player_total = total(session[:player_cards])
  dealer_total = total(session[:dealer_cards])
  if dealer_total >= player_total
    @error = "The dealer wins this hand with #{dealer_total}. You stayed with #{player_total}. your balance is #{session[:player_money]}"
    session[:dealer_hit] = false
    @show_hit_stay_btn = false
    @play_again = true
    erb :game
  else
    session[:player_money] += (session[:player_bet]*2)
    @success = "#{session[:player_name]}, you won with #{player_total}. The dealer stayed with #{dealer_total}. Your new balance is #{session[:player_money]}"
    session[:dealer_hit] = false
    @show_hit_stay_btn = false
    @play_again = true
    erb :game
  end

end