
require_relative 'blackjack_player'
require_relative 'blackjack_game'
require_relative 'blackjack_tools'

#Show title
srand
system('cls')
show_text_banner('Welcome to Blackjack', 1)

#User input for initialize
print 'Your Name: '
name = gets.chomp.downcase.capitalize

print 'Players: '
number_of_player = gets.chomp.to_i
number_of_player = (number_of_player < 2)? 2 : number_of_player

puts 'Decks (1~8): 4'
#number_of_decks = gets.chomp.to_i
number_of_decks = 4 #(number_of_decks < 1)? 1 : ((number_of_decks > 8)? 8 : number_of_decks)

puts 'Betting Chips: 1000'
#number_chips = gets.chomp.to_i
number_chips = 1000 #(number_chips < 100)? 100 : ((number_chips > 10000)? 10000 : number_chips)

puts 'Betting Odds: 1.5'
odds = 1.5

#Player Initialization
players = Blackjack_players.new(number_of_player, number_of_player - 1)
i = 0
while i < players.count
  if i == 0
    players[0].name = name
    players[0].is_human = 1
  else
    players[i].name = 'COM' + i.to_s
  end
  players[i].total_chips = number_chips
  players[i].set_winning_rate(1, players.count)
  i = i + 1
end
players[1].bet_pattern = 1

#Card Initialization
cards = Card_deck.new(number_of_decks)

game = Blackjack_game.new(players, cards, odds)
while game.continue?
  game.start

  show_text_banner('', 1)
  print 'Do you want to try again? [Y]es/[N]o: '
  answer = gets.chomp
  if answer.downcase != 'y'
    game.quit
  else
    game.restart	
  end
end
