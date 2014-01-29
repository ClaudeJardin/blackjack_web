require 'rubygems'
require 'sinatra'
require_relative 'source/blackjack_card'
require_relative 'source/blackjack_player'
require_relative 'source/blackjack_game'

set :sessions, true

get '/' do
  session.clear;
  if session[:player_name]
    redirect '/game'  
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  session[:player_name] = (params[:player_name] == '')? '(No Name)' : params[:player_name]
  redirect '/game'
end

get '/game' do
  #Initialize players 
  players = Blackjack_players.new(5, 4)
  i = 0
  while i < players.count
    if i == 0
      players[0].name = session[:player_name]
      players[0].is_human = 1
    else
      players[i].name = 'COM' + i.to_s
    end
    players[i].total_chips = 1000
    players[i].set_winning_rate(1, players.count)
    i = i + 1
  end
  players[1].bet_pattern = 1

  #Initialize cards
  cards = Card_deck.new(2)
  
  session[:players] = players
  session[:cards] = cards
  session[:game] = Blackjack_game.new(players, cards, 1.5)
  session[:game].start
  
  if session[:game].current_player.state != 'normal'
    session[:game].auto_proceed
  end
  
  erb :game, :layout => :'game_layout'
end

post '/game/player/hit' do
  session[:game].dealing
  if session[:game].current_player.state != 'normal'
    session[:game].auto_proceed
  end
  erb :game, :layout => :'game_layout'
end

post '/game/player/stay' do
  session[:game].stay
  session[:game].auto_proceed
  erb :game, :layout => :'game_layout'
end

post '/game/player/restart' do
  session[:game] = nil
  redirect '/game'
end
