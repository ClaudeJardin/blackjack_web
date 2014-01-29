
require_relative 'blackjack_card'
require_relative 'blackjack_player'

class Blackjack_game
  attr_accessor :step
  def initialize game_players, game_cards, game_odds
    @players = game_players
	@cards = game_cards
	@odds = game_odds
	@status = 'Continue'
	@rounds = 1
	@turn = 0
	@step = 0
	
	#For Web UI
	@cur_max_delay = 0
  end
  def continue?
    if @status == 'Continue'
      return true
    end
    false
  end
  def current_player
    @players[@turn]  
  end
  def initial_dealing?
    @step == 0
  end
  def human_player
    @players.each do |player|
	  if player.is_human == 1
	    return player
	  end
	end
	nil
  end
  def human_player_i
    @players.count.times do |k|
	  player = @players[k]
	  if player.is_human == 1
	    return k
	  end
	end
	-1
  end
  def quit
    @status = 'Quit'
  end
  def dealing
    if @step == 0
      @step = @step + 1	
	end
    
	card_dealing(self.current_player, true)
    
  end
  def stay
    self.current_player.stay
	@step = @step + 1
  end
  def auto_proceed
    if @status != 'Continue'
	   return;
	end

    turn = (@turn + 1) % @players.count
	
	#Dealing card
    while turn != @players.dealer
	  player = @players[turn]
	  if player.bankrupt?
	    turn = (turn + 1) % @players.count
	    next
	  end
	
      answer = 0
	  while answer != 2
	    if player.state == 'normal'
	      answer = player.computer_hit_or_stay
	      if answer == 1
	        card_dealing(player, true)
		  else
		    player.state = 'stay'
	      end
	    else
	      answer = 2
        end		
	  end
	  puts ''
	  turn = (turn + 1) % @players.count
    end

    #dealer hit

    if @players.dealer_player.state == 'normal' && @players.dealer_player.points < 17
      sum = @players.dealer_player.compute_sum
      while sum < 17
        card_dealing(@players.dealer_player, true)
	    sum = @players.dealer_player.compute_sum
      end
    end
    #competition
    @players.compete
	@step = @step + 1
    @status = 'Finished'
  end
  def finished?
    @status == 'Finished'
  end
  def start  
    @cards.refresh
    #show_text_banner('Round ' + @rounds.to_s, 1)
    #@players.show_table
  
    @players.new_game
    
	#Betting
    #show_text_banner('Place Chips', 1)
    #while turn != @players.dealer
    #  player = @players[turn]
	#  if player.bankrupt?
	#    turn = (turn + 1) % @players.count
	#    next
	#  end
	#  print player.name + ': '
	#  bet = 0
	#  if player.is_human == 1
	#    bet = gets.chomp.to_i
	#    bet = (bet > player.total_chips)? player.total_chips : bet 
	#  else
	#    thinking(2)
	#    bet = player.compute_bet(@odds)
	#    puts bet.to_s
	#  end
	#  player.bet = bet
	#  turn = (turn + 1) % @players.count
    #end
    #puts ''
  
    #Initial dealing
    #show_text_banner('Initial Dealing', 1)
    @players.each do |player|
      if !player.bankrupt?
	    visible = (player == @players.dealer_player)? false : true
        card_dealing(player, visible)
	    card_dealing(player, visible)
	  end
    end
	@turn = (@players.dealer + 1) % @players.count
	

  end 
  
  def restart
    @rounds = @rounds + 1
	@step = 0
	@cur_max_delay = 0
  end
  def card_dealing player, visible
    player.before_dealing
    if player.state == 'normal'
      @cards[0].visible = visible
      player.get_card(@cards[0])
      player.points = player.compute_sum
      @cards.pop_card
      player.update_state
	end
  end
  def hit_or_stay
    answer = 0
    answer = gets.chomp.downcase
    if answer == 'h'
      return 1
    end
    2
  end
  
  #Methods for Web UI: computer delay time of animation effects for UI elements 
  def initial_dealing_time
	delay_time_of_card(@players.count - 2, 1)
  end
  def delay_time_of_states player_index
    if player_index == @players.dealer
	  return 0
	end
    if !@players[player_index].normal?
	  if @players[player_index].card_count == 2 
	    if @players[player_index].blackjack?
	      delay_time = delay_time_of_card(player_index, 1) + 1
		  @cur_max_delay = (delay_time > @cur_max_delay)? delay_time : @cur_max_delay
		  return delay_time
		end
		k = player_index - 1
		while k >= 0 && @players[k].card_count == 2
		  k = k - 1
		end
		prev = (k >= 0)? (player_index - k) * 2 : player_index * 2
		delay_time = (k >= 0)? delay_time_of_card(k, @players[k].card_count - 1) + prev + 1 : prev + self.initial_dealing_time + 1
		@cur_max_delay = (delay_time > @cur_max_delay)? delay_time : @cur_max_delay
		return delay_time
	  end
	  delay_time = delay_time_of_card(player_index, @players[player_index].card_count - 1) + 1
	  @cur_max_delay = (delay_time > @cur_max_delay)? delay_time : @cur_max_delay
	  return delay_time
	end
	0
  end
  def delay_time_of_hit player_index, card_index
    if card_index < 2 || player_index == @players.dealer || @players[player_index].is_human == 1
	  return 0
	end
	delay = delay_time_of_card(player_index, card_index)
	delay = (delay == 0)? 0 : delay - 2
  end
  def delay_time_of_buttons
    if self.initial_dealing? 
	  if self.human_player.blackjack?
	    return 0
	  else
	    return self.initial_dealing_time + 1
	  end
	elsif !self.human_player.normal?
	  return 0
	end
	2
  end
  
  def recursive_delay_time player_index, card_index
    if card_index < 2
	  if !self.initial_dealing?
	    return 0
	  end
	  if player_index == 0
	    return 2 + card_index
	  elsif player_index != @players.dealer
	    prev = recursive_delay_time(player_index - 1, 1)
		extra = (@players[player_index - 1].blackjack?)? 2 : 0
		return prev + extra + (card_index + 1)
	  end
	  return card_index
	end
	
	#if card_index >= 2, which means it is not initial dealing
	if player_index == 0
	  return (card_index == @players[0].card_count - 1 && @players[0].state != 'stay')? 1 : 0
	elsif @players[player_index - 1].card_count == 2
	  k = player_index - 1
	  while k >= 0 && @players[k].card_count == 2 && !@players[k].normal?
		k = k - 1
	  end
	  prev = (k >= 0)? (player_index - k) * 2 : player_index * 2
	  prev = (k >= 0)? delay_time_of_card(k, @players[k].card_count - 1) + prev + 1 : prev + self.initial_dealing_time + 1
	else
	  prev = recursive_delay_time(player_index - 1, @players[player_index - 1].card_count - 1) 
	end
    extra = 2
    return prev + extra + (card_index - 1) * 3
  end
  
  def delay_time_of_card player_index, card_index
	recursive_delay_time(player_index, card_index)
  end
  def dealer_card_delay card_index
    @cur_max_delay + card_index + 2
  end
  def delay_time_of_result
    if !self.finished?
	  return 0
	end
    delay_time = @cur_max_delay + @players.dealer_player.card_count + 4
  end
  def delay_of_try_again
    if !self.finished?
	  return 0
	end
    delay_time = self.delay_time_of_result + 2
  end
  def delay_time_of_dealer_result
    @players.non_dealer_players.each do |player|
	  if player.normal?
	    return 0
	  end
	end
    delay_time = dealer_card_delay(@players.dealer_player.card_count - 1) + 1
  end
  def dealer_card_style front_back, card_index
    dealer_style = 'player_' + front_back + '_style'
	if !self.initial_dealing? && card_index < 2
	  return 'dealer_' + front_back + '_style'
	end
	dealer_style
  end
  def dealer_card_id front_back, card_index
    delay_time = self.dealer_card_delay(card_index)
	if card_index < 2
	  if self.finished? && self.initial_dealing?
	    return front_back + '_0_' + (card_index + 1).to_s + '_' + delay_time.to_s
	  elsif self.finished? 
		return front_back + '_' + delay_time.to_s	
	  elsif self.initial_dealing? 
		return 'dealer_' + front_back + '_0_' + (card_index + 1).to_s 					
	  else 
		return 'dealer_' + front_back + '_1_' + (card_index + 1).to_s 
	  end 
	else
	  return front_back + '_' + delay_time.to_s 	
	end
  end
  def dealer_result
    if @players.dealer_player.blackjack?
	  return 'Dealer gets blackjack!'
	elsif @players.dealer_player.busted?
	  return 'Dealer gets busted!'
	else
	  return 'Dealer gets ' + @players.dealer_player.points.to_s + ' points.'
	end
  end
  def player_result player_index
    @players[player_index].result
  end
end



















