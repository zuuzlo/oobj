#Blackjack OOP
require 'rubygems'
require 'pry'

class Card
  attr_accessor :suit, :value

  def initialize(v, s)
    @suit = s
    @value = v
  end

  def show_nice(down = false)
    if down
      "| Card face down  |"
    else
      "| #{value} of #{suit} |"
    end
  end

  def to_s
    show_nice
  end
end

class Deck
  attr_accessor :cards, :value, :suit

  def initialize(decks = 1) # 1 deck = 52 cards
    @cards = []
    decks.times do | x |
      %w(Harts Diamonds Clubs Spades).each do |suit|
        %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace).each do |value|
          @cards << Card.new(value, suit)
        end
      end
    end
  end

  def shuffle
    @cards.shuffle!
  end

  def deal_card
    @cards.pop
  end

  def cut(location) 
    @cards.rotate!(location)
  end

  def in_deck
    @cards.size
  end

  def next_card
    @cards.last
  end

  def show_deck
    "#{@cards}"
  end
end

class Hand
  attr_accessor :hand_cards, :value, :suit
  @@number_of_hand = 0
  def initialize
    @hand_cards = []
    @@number_of_hand += 1
  end

  def get_card(card)
    @hand_cards << card
  end

  def to_s
    out = ""
    @hand_cards.each do | card | 
       out << "#{card} "
    end
    out
  end

  def dealer_show
    i = 0 
    print "Dealer has: "
    @hand_cards.each do | card |
      if i < 1 
        print "| Card Face Down | "
      else
      #binding.pry  
        print "#{card}"
      end
      i += 1
    end
    puts
  end

  def hand_total
    total = 0
    
    @hand_cards.each do |e|
      if e.value == "Ace"
        total += 11
      elsif e.value.to_i == 0
        total += 10
      else
        total += e.value.to_i
      end
    end
    
    @hand_cards.select{ | e | e.value == "Ace"}.count.times do
      total -= 10 if total > 21
    end
    
    total
  end

  def how_many_hands
    @@number_of_hand
  end

  def hand_split
   @hand_cards.pop
  end 

  def hand_blackjack?
    hand_total == 21 && @hand_cards.count == 2
  end

  def hand_busted?
    hand_total > 21  
  end

  def soft_17?
    @hand_cards.select { | e | e.value == "Ace"}.count > 0  
  end
  
  def hand_clear
    @hand_cards = []
  end

  def number_of_cards
    @hand_cards.size
  end

  def hand_can_split?
    temp1 = Hand.new
    temp2 = Hand.new
    if number_of_cards > 2 
      false
    else
      temp1.get_card(@hand_cards[0])
      temp2.get_card(@hand_cards[1])
      if temp1.hand_total == temp2.hand_total
        true
      else
        false
      end
    end
  end
end 

class Player
  attr_accessor :name, :seats, :player_hand, :bank_roll, :bet_size, :committed, :hand_played

  def initialize(name, seat, br)
    @name = name
    @seats = seat
    @player_hand = {}
    @bank_roll = br.to_i
    @bet_size = {}
    @committed = 0 # amount of money bet on hands during current hand
    @hand_played = {}
  end

  def bet_lose
    @bank_roll -= @bet_size
  end

  def bet_win
    @bank_roll += @bet_size
  end

  def money_can_bet
    @bank_roll - @committed
  end

  def bet_clear(num)
    @bet_size[num] = 0
  end

  def hand_played_clear(num)
    @hand_played[num] = false
  end
end

class Blackjack
  attr_accessor :deck, :dealer, :players
  
  def initialize
    @players = []
    @players_list = []
    @dealer = Hand.new
    #@deck = Deck.new
    #@deck.shuffle
    @how_many_decks = 1
  end

  def start
    get_players
    buy_in
    introduction
    card_shuffle(@how_many_decks.to_i)
    @play = true
    while @play
      bet_on_hand
      first_deal
      player_loop
      dealer_loop
      win_lose
      do_it_again
    end
  end
=begin
  def replay
    clear_hands
    bet_on_hand
    first_deal
    player_loop
    dealer_loop
    win_lose
    do_it_again
  end
=end  
  def get_players
    
    while true
      puts"How many players today? 1-6"
      @num_of_players = gets.chomp
      if @num_of_players.to_i > 6 || @num_of_players.to_i < 1
        puts "Enter a number between 1 and 6!"
        next
      else
        break
      end
    end
    @seats_left = 6 - @num_of_players.to_i
    @num_of_players.to_i.times do |x|
      puts "Enter player #{x.to_i + 1} name"
      @players_list << gets.chomp
    end

    while @seats_left > 0
      puts "#{@seats_left} are left."
      puts "Would anyone like to play an additonal hand? (y-yes n-no)"
      add_seat = gets.chomp
      if add_seat == "y"
        puts "Who?"
        @players_list << gets.chomp
        @seats_left -= 1
      else
        break
      end
    end
    @players_list.sort!
    @player_hash = @players_list.each_with_object(Hash.new(0)) { |player, hash| hash[player] += 1 }
    y = 0
    @player_hash.each do |name, seats|
      bank_roll = 0
      @players << Player.new(name, seats, bank_roll)
      seats.to_i.times do | hands |
        @players[y].player_hand[hands.to_s] = Hand.new
        @players[y].bet_size[hands.to_s] = 0
        @players[y].hand_played[hands.to_s] = false
      end
      y += 1
    end
    while true
      puts
      puts "How many card decks would you like to play with? (1 - 6)"
      @how_many_decks = gets.chomp
      if @how_many_decks.to_i < 1 || @how_many_decks.to_i > 6
        puts "Please enter a valid number of decks can only be 1 thru 6"
        next
      else
        break
      end
    end
  end

  def buy_in
    puts "Welcome to the Blackjack Table."
    @players.each do | player |
      while true
        puts "#{player.name}, what is your buy in amount?"
        money = gets.chomp
        if money.to_i <= 0
          puts "Enter valid buy in amount!"
          next
        else
          break
        end
      end
      player.bank_roll = money.to_i
    end
  end

  def introduction
    seat = 1
    puts
    @players.each do | player |
      puts "#{player.name} is at the table with #{player.bank_roll} dollars."
      #binding.pry
      if player.seats > 1
        puts "#{player.name} is playing table hands #{seat} thru #{seat - 1 + player.player_hand.count}"
        seat = seat + player.player_hand.count 
      else
        puts "#{player.name} is playing table hand #{seat}"
        seat = seat + 1
      end
      puts
    end
  end

  def bet_on_hand
    puts
    @players.each do | player |
      if player.bank_roll <= 0
        puts
        puts "#{player.name} you are broke."   
        while true
          puts "How much would you like to add to your bankroll?"
          money = gets.chomp
          if money.to_i <= 0
            puts "Enter valid buy in amount!"
            next
          else
            break
          end
        end
        player.bank_roll = money.to_i
      end

      puts "#{player.name} your bankroll is #{player.bank_roll}"
      player.bet_size.each do | num, bet |
        while true
          player.committed = 0
          player.bet_size.each do | num, bet |
            player.committed += bet
          end
          puts "#{player.name} place a bet on your hand # #{num.to_i + 1} you have #{player.money_can_bet}"
          bet_is = gets.chomp
          if bet_is.to_i <= 0 || bet_is.to_i > player.money_can_bet
            puts "Please make an approiate bet! that is less than #{player.money_can_bet}"
            next
          end
          player.bet_size[num] = bet_is.to_i
          break
        end
      end  
    end      
  end

  def card_shuffle(nu_decks)
    @deck = Deck.new(nu_decks)
    @deck.shuffle
    puts "#{@players[rand(@players.length.to_i)].name}, would you like to cut the cards? (y/n)"
    cuts_answer = gets.chomp
    if cuts_answer == "y"
      puts"At what card to cut? (1-#{nu_decks.to_i * 52})"
      cut_location = gets.chomp
      if cut_location.to_i > 1 && cut_location.to_i < (nu_decks.to_i*52)
        @deck.cut(cut_location.to_i)
      else
        puts"Sorry, cut location out of range, cards not cut"
      end 
    end
    puts "Dealer burns first card..."
    @deck.deal_card
  end

  def first_deal
    puts
    puts "Here come the cards ..."
    puts
    2.times do
      @players.each do | player |
        player.player_hand.each do | num, hand |
          #binding.pry
          hand.get_card(@deck.deal_card)
        end
      end
      @dealer.get_card(@deck.deal_card)
    end
    show_cards_all
  end

  def player_loop
    @redo_player_loop = false
    @dealer_hits = []
    @players.each do | player |
      player.player_hand.each do | num, hand |
        hit = true
        hit = false if (hand.hand_blackjack? || @dealer.hand_blackjack?) || @redo_player_loop || player.hand_played[num]

        while hit
          puts
          puts show_cards_each(player, hand, num)
          puts
          #binding.pry
          if hand.number_of_cards == 2 && hand.hand_can_split? && player.bet_size[num] < player.money_can_bet
            puts "==> #{player.name}, Hit, Stay, Split or Double Down? (h-Hit, s-Stay, p-Split or d-Double Down)"
          elsif hand.number_of_cards == 2 && player.bet_size[num] < player.money_can_bet
            puts "==> #{player.name}, Hit, Stay, or Double Down? (h-Hit, s-Stay or d-Double Down)" 
          else
            puts "==> #{player.name} Hit or Stay? (h-Hit or s-Stay)"
          end

          action = gets.chomp
          if action == "h"
            puts "#{player.name} hand #{num.to_i + 1} gets: \t#{@deck.next_card}"
            hand.get_card(@deck.deal_card)
          elsif action == "d" &&  hand.number_of_cards == 2 && player.bet_size[num] < player.money_can_bet 
           puts "#{player.name} hand #{num.to_i + 1} doubles down and gets: \t#{@deck.next_card}"
           hand.get_card(@deck.deal_card)
           player.bet_size[num] *= 2
           player.committed += player.bet_size[num]
           player.hand_played[num] = true
           hit = false
          elsif action == "p" && hand.number_of_cards == 2 && hand.hand_can_split? && player.bet_size[num] < player.money_can_bet
            #code for spliting cards         
            @temp = Hand.new
            @temp_hand_number = num + "a"
            @temp_player = player.name
            @temp_bet_size = player.bet_size[num]
            @temp.get_card(hand.hand_split)
            hand.get_card(@deck.deal_card)
            @temp.get_card(@deck.deal_card) 
            @redo_player_loop = true        
          else
            player.hand_played[num] = true
            hit = false
          end
          if hand.hand_busted?
            puts "#{player.name} your hand #{num.to_i + 1} busted"
            puts "With a total #{hand.hand_total}"
            puts
            @dealer_hits << false
            player.hand_played[num] = true
            hit = false
          else
            @dealer_hits << true
          end
        end
      end
    end
    if @redo_player_loop
      @players.each do | player |
        if player.name == @temp_player
          player.player_hand[@temp_hand_number] = Hand.new
          player.bet_size[@temp_hand_number] = @temp_bet_size
          player.hand_played[@temp_hand_number] = false
          player.player_hand[@temp_hand_number].get_card(@temp.hand_split)
          player.player_hand[@temp_hand_number].get_card(@temp.hand_split)
        end
      end
      #binding.pry
      @redo_player_loop = false
      player_loop
      #get players hands straight for split : recall loop 
    end
  end

  def dealer_loop
    puts
    puts "Dealer flips bottom card ..."
    puts
    puts "Dealer has #{@dealer} for a total of #{@dealer.hand_total}"
      if @dealer_hits.select{ | e | e == true}.count > 0
        dealer_hit = true
      else
        dealer_hit = false
      end
  
    while dealer_hit
      puts
      puts "Dealer's total #{@dealer.hand_total}"
      binding.pry
      if @dealer.hand_total >= 17 && @dealer.hand_total <= 21 && @dealer.soft_17? != true
          dealer_hit = false
      end
    
      if @dealer.hand_total > 21
        puts "Dealer BUSTED!!!"
        dealer_hit = false
      end

      if @dealer.hand_total < 17 || (@dealer.hand_total == 17 && @dealer.soft_17?)
        puts "Dealer gets: \t#{@deck.next_card}"
        @dealer.get_card(@deck.deal_card)
        puts "Dealer has #{@dealer} for a total of #{@dealer.hand_total}"
      end
    end
  end

  def win_lose
    @players.each do | player |
      player.player_hand.each do | num, hand |
        #binding.pry
        if hand.hand_busted? == false && @dealer.hand_busted? == false
          show_cards_each(player, hand, num)
          puts
          puts "Dealer has: #{@dealer.hand_total}"
        end

        if (hand.hand_total > @dealer.hand_total && hand.hand_busted? == false) || (@dealer.hand_busted? && hand.hand_busted? == false) || (hand.hand_blackjack? && @dealer.hand_blackjack? == false)
          puts
          puts "#{player.name}'s hand # #{num.to_i + 1} WINS bet of #{player.bet_size[num]} !!!"
          if hand.hand_blackjack?
            player.bank_roll += player.bet_size[num] * 1.5 
          else
            player.bank_roll += player.bet_size[num]
          end
        elsif hand.hand_total == @dealer.hand_total && hand.hand_busted? == false
          puts
          puts "#{player.name}'s hand # #{num.to_i + 1} PUSHES!!!"
        else
          puts
          puts "#{player.name}'s hand # #{num.to_i + 1} LOSES bet of #{player.bet_size[num]} !!!"
          player.bank_roll -= player.bet_size[num]
        end       
      end
    end   
  end

  def results

  end

  def show_cards_each(player, hand, num)
    puts
    puts"#{player.name}'s hand #{num.to_i + 1} has #{hand.to_s} for a total of #{hand.hand_total}"
  end

  def show_cards_all
    puts
    @players.each do | player |
      player.player_hand.each do | num, hand |     
        puts "#{player.name}'s hand # #{num.to_i + 1} has #{hand.to_s} for a total of #{hand.hand_total}"
        puts "#{player.name}'s hand # #{num.to_i + 1} has Blackjack!!!" if hand.hand_blackjack?
        puts "#{player.name}'s hand # #{num.to_i + 1} is Busted." if hand.hand_busted?
        puts
      end
    end
    #binding.pry
    puts "#{@dealer.dealer_show}"
    puts "Dealer has Blackjack!!! #{@dealer.hand_cards}" if @dealer.hand_blackjack?
    puts "Dealer Busted!!!" if @dealer.hand_busted?
    puts
  end

  def clear_hands
    #remove any hands that have an "a" on the key along with bets and hand_played split hands
    @players.each do | player |
      player.player_hand.each do | num, hand |
        #binding.pry
        hand.hand_clear
      end
      player.player_hand.delete_if { | key, value | key.include? "a" }
      player.bet_size.delete_if { | key, value | key.include? "a" }
      player.hand_played.delete_if { | key, value | key.include? "a" }
    end
    @dealer.hand_clear
    @temp.hand_clear if @temp != nil
    @players.each do | player |
      player.bet_size.each do | num, bet |
        player.bet_clear(num)
        player.hand_played_clear(num)
      end
    end
  end

  def do_it_again
    puts
    puts "==> Play again? (y-yes / n-no)"
    play_again = gets.chomp
    #binding.pry
    if @deck.in_deck < @dealer.how_many_hands * 4 && play_again == "y"
      puts "Time to shuffle" 
      card_shuffle(@how_many_decks.to_i)
    end

    @play = false if play_again == "n"
    clear_hands
  end
end

game = Blackjack.new
game.start

