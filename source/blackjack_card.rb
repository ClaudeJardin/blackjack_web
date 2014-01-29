class Card
  attr_reader :face, :suit
  attr_accessor :visible
  def initialize card_suit, card_face, is_visible
    @suit = card_suit
	@face = card_face
	@visible = is_visible
  end
  def face_of_card
    face_values = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
    return (@visible == true)? face_values[@face - 1] : '?'
  end
  def face_to_s
    face_values = ['ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'jack', 'queen', 'king']
    return face_values[@face - 1]
  end
  def suit_of_card
    suit_strings = ['clubs', 'diamonds', 'hearts', 'spades']
	return suit_strings[@suit]
  end
end
class Card_deck
  def initialize number_of_decks
	@number = number_of_decks
    self.card_init
  end
  def card_init
    inx = 0
	@cards = []
    amount_cards = @number * 52
    amount_cards.times do |inx| 
      @cards << Card.new(inx / (13 * @number), inx % 13 + 1, false)
    end
	self.card_shuffle
	#@cards[0] = Card.new(0, 1, true)   #For testing
	#@cards[1] = Card.new(0, 10, true)
	
  end
  def [](inx)
    @cards[inx]
  end
  def count
    @cards.length
  end
  def pop_card
    @cards.delete_at(0)
  end
  def not_enough?
    @cards.length < @number * 26
  end
  def refresh
    if not_enough?
      self.card_init
    end	  
  end
 
  #Recursive Shuffle
  def card_shuffle 
    shuffle = []
    @cards = recursive_shuffle(@cards, shuffle)
  end

  
  def recursive_shuffle original_array, shuffle_array
  
    if original_array.length == 0
      return shuffle_array
    end
    from_index = rand(original_array.length)
    to_index = 0
    if shuffle_array.length > 0
      to_index = rand(shuffle_array.length + 1)
    end
    shuffle_array.insert(to_index, original_array[from_index])
    original_array.delete_at(from_index)
    recursive_shuffle original_array, shuffle_array
  end
end


