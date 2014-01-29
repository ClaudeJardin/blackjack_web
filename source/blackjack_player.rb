class Player
  attr_reader :cards, :rate, :hit_stay
  attr_accessor :name, :points, :state, :bet, :total_chips, :result
  def initialize player_name
    @name = ''     
	@is_human = 0      #human player? 0 denotes no; otherwise, yes
	@state = 'normal'  #player state
	@result = 'normal'
    @cards = []        #cards that the player holds, a set for storing card element
	@points = 0        #points
	@bet = 0
    @total_chips = 0   #betting_chips
	@hit_stay = 0 
	@bet_pattern = 0 
	@history = [] 
	@total_win = 1     #no. of rounds the player won
	@total_round = 2   #total rounds players game
    @rate = 0.5        #winning rate
    @previous_card_count = 0	
  end

  def card_count
    @cards.length
  end
  def stay
    @state = 'stay'
  end
  def won?
    @result == 'won'
  end
  def tie?
    @result == 'tie'
  end
  def lost?
    @result == 'lost'
  end
  def normal?
    @state == 'normal'
  end
  def stay?
    @state == 'stay'
  end
  def get_cards_string
    result = ''
    @cards.length.times do |i|
      result = result + @cards[i].face_of_card
	  if i < @cards.length - 1
	    result = result + ', '
	  end
    end
    result
  end
  def is_human
    @is_human
  end
  def is_human=(flag)
    @is_human = (![0, 1].include?(flag))? 0 : flag
  end
  #Show cards or not?
  def show_cards
    @cards.each do |card|
      card.visible = true
    end
  end
  def before_dealing
    @previous_card_count = @cards.length
  end
  def get_new_card?
    @card.length > @previous_card_count
  end
  def get_card card
    @cards.push(card)
  end
  def card_invisble?
    @cards.each do |card|
      if !card.visible
	    return true
	  end
    end
    false
  end

  #Restart a new game, and then clear the status for players
  def clear_state
    @state = 'normal'
	@cards = []
	@points = 0
	@bet = 0
  end
  def bet_pattern
    @bet_pattern
  end
  def bet_pattern=(pattern)
    if pattern >= 0
      @bet_pattern = pattern
    end
  end

  def set_winning_rate win_round, total_round
    if total_round > 0
      @total_win = win_round
	  @total_round = total_round
	  @rate = win_round.to_f / total_round.to_f
    end
  end

  def compute_bet odds
    @bet = 0
    if @bet_pattern == 0
      @bet = 1 + rand(@total_chips)
    elsif @bet_pattern == 1
      @bet = (@total_chips.to_f * ((odds * 0.5 - 0.5) / odds)).to_i
	  @bet = (@bet < 0 && @total_chips > 0)? 1 : @bet
    end
    @bet
  end
  #Compute the sums of cards
  def compute_sum
    if @cards == nil || @cards.length == 0
      return 0
    end
  
    #Compute initial points
    sum = 0
    @cards.each do |card|
      sum = sum + ((card.face > 10)? 10 : ((card.face == 1)? 11 : card.face))
    end
  
    #Fix the sum if possible, when the points is larger than 21
    j = @cards.length - 1
    while sum > 21 && j >= 0
	  card = @cards[j]
	  if card.face == 1  #There is an Ace
	    sum = sum - 11 + 1
	  end
	  j = j - 1
    end
    sum
  end
  
  def computer_hit_or_stay
    answer = 2
    if @hit_stay == 0
      sum = self.compute_sum
      answer = 2
      if sum < 21
        answer = rand(2) + 1
      end
    end
    answer
  end
  def bankrupt?
    if @total_chips <= 0
      return true
    end
    false
  end
  def blackjack?
    @state == 'blackjack'
  end
  def busted?
    @state == 'busted'
  end
  #Update player's state
  def update_state
    sum = self.compute_sum
    if sum > 21
      @state = 'busted'
    elsif sum == 21
      @state = 'blackjack'
    end
  end
  def result_update dealer_player, odds
    if @result == 'won' 
      amount = (@bet.to_f * odds).to_i
      @total_chips = @total_chips + amount
	  dealer_player.total_chips = dealer_player.total_chips - amount
	  @total_win = @total_win + 1
	  @history.push('won')
    elsif @result == 'lost'
      @total_chips = @total_chips - @bet
	  dealer_player.total_chips = dealer_player.total_chips + @bet
      @history.push('lost')
    else
      @history.push('tie')
    end
    @total_round = (@result == 'won' || @result == 'lost')? @total_round + 1 : @total_round
    @rate = (@total_round > 0)? @total_win.to_f / @total_round.to_f : @rate
  end
end

class Blackjack_players 
  attr_reader :dealer
  def initialize number, dealer_index
    @players = []
	number = number > 6 ? 6 : (number < 2 ? 2 : number)
	@dealer = (dealer_index < 0 || dealer_index >= number)? 0 : dealer_index
	number.times do |i|
	  @players.push(Player.new(''))
	end
  end
  def dealer_player
    @players[@dealer]
  end
  def non_dealer_players
    @players.select {|p| p != self.dealer_player}
  end
  def count
    @players.length
  end
  def each(&block)
    @players.each do |player|
	  block.call(player)
	end
  end
  def [](inx)
    @players[inx]
  end
  def new_game
    @players.each do |player|
      player.clear_state
	end
  end  
  #Show a table of players' state
  def show_table
    hit_stay = ['RANDOM']
    bet_pattern = ['RANDOM', 'KELLY']
  
    dealer_player = self.dealer_player
    puts 'Dealer: ' + dealer_player.name + '($' + dealer_player.total_chips.to_s + ')'
    puts ''
  
    turn = (@dealer + 1) % @players.count
  
    name_width = 10
    hit_stay_width = 15
    bet_pattern_width = 20
    chips_width = 15
    rate_width = 15
    puts 'Name'.ljust(name_width) + 'Hit/Stay'.rjust(hit_stay_width) + 'Bet Pattern'.rjust(bet_pattern_width) + 'Chips'.rjust(chips_width) + 'Rate'.rjust(rate_width)
    while turn != @dealer
      player = @players[turn]
	  name = player.name + ((player.bankrupt?)? ' (X)' : '')
	  hit_stay_string = (player.is_human == 1)? 'x' : hit_stay[player.hit_stay]
	  bet_pattern_string = (player.is_human == 1)? 'x' : bet_pattern[player.bet_pattern]
	  chips_string = player.total_chips.to_s
	  rate_string = (player.rate * 100.0).round(2).to_s + '%' 
	
	  puts name.ljust(name_width) + hit_stay_string.rjust(hit_stay_width) + bet_pattern_string.rjust(bet_pattern_width) + chips_string.rjust(chips_width) + rate_string.rjust(rate_width)
	
	  turn = (turn + 1) % @players.count
    end
    puts ''
  end
  #competition
  def compete
    @players.each do |player|
	  if player != self.dealer_player
	    if self.dealer_player.state == 'blackjack'
	      player.result = (player.state == 'blackjack')? 'tie' : 'lost'
	    elsif self.dealer_player.state == 'busted'
	      player.result = (player.state == 'busted')? 'lost' : 'won'
	    elsif player.state == 'busted'
	      player.result = 'lost'
	    else
	      player.result= (player.points > self.dealer_player.points)? 'won' : ((player.points == self.dealer_player.points)? 'tie' : 'lost')
        end	  
	  end
    end
  end
  
end

