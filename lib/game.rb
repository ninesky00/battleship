require './lib/cell'
require './lib/ship'
require './lib/board'
require './lib/player'
require 'pry'

class Game
  attr_reader :player_board,
              :computer_board,
              :player,
              :computer
  def initialize
    setup
  end

  def health_check
    @player.health
    @computer.health
  end

  def computer_count_cells_with_ships
    @computer_board.cells.values.count do |cell|
      !cell.empty?
    end
  end

  def create_new_ship
    puts "Enter ship name"
    ship_name = gets.chomp.to_s
    puts "Enter ship length"
    ship_length = gets.chomp.to_i
    if ship_length < 2 || ship_length > Math.sqrt(board.cells.length)
        "Invalid length, try again"
    else
    Ship.new(ship_name, ship_length)
    end
  end

  def setup
    @player = Player.new
    @computer = Player.new
    @player_board = Board.new
    @player_board.generate
    @computer_board = Board.new
    @computer.add_board(@computer_board)
    @computer_board.generate
    @player.add_ship(@player_cruiser = Ship.new("Cruiser", 3))
    @player.add_ship(@player_submarine = Ship.new("Submarine", 2))
    @computer.add_ship(@computer_cruiser = Ship.new("Cruiser", 3))
    @computer.add_ship(@computer_submarine = Ship.new("Submarine", 2))
    @computer_board.place(@computer_cruiser, @computer.random_coordinates(@computer_cruiser))
    @computer_board.place(@computer_submarine, @computer.random_coordinates(@computer_submarine))
    health_check
  end

  def main_menu
    puts "\n"
    puts "Welcome to BATTLESHIP".center(60, "=")
    input = ""
    until input == "p" do
      puts "\nEnter p to play or q to quit"
      print '> '
      input = gets.chomp.to_s.downcase
      if input == "p"
        play_game
      elsif input == "q"
        exit
      else
        puts "\n\nWrong input, please try again."
      end
    end
  end

  def play_game
    setup
    # create custom ships? y/n
    @computer_targets = @player_board.cells.keys
    puts "PLACE SHIPS".center(60, "=")
    puts "I have laid out my ships on the grid."
    puts "You now need to lay out your two ships."
    @player.ships.each { |ship| player_place(ship) }
    firing_phase
  end

  def player_place(ship)
    ship_coordinates = [""]
    until ship_coordinates.all? { |coord| @player_board.valid_coordinate?(coord) } &&
      @player_board.valid_placement?(ship, ship_coordinates) do
        puts
        puts @player_board.render(true)
        puts "\nThe Cruiser is three units long and the Submarine is two units long."
        puts "Enter the squares for your #{ship.name} (#{ship.length} spaces)"
        print '> '
        ship_coordinates = gets.chomp.to_s.upcase.split(" ")
        if !ship_coordinates.all? { |coord| @player_board.valid_coordinate?(coord) }
          puts
          puts "What board are you playing on?".center(60, "=")
        elsif !@player_board.valid_placement?(ship, ship_coordinates)
          puts
          puts "Invalid coordinates, please try again.".center(60, "=")
        end
      end
      @player_board.place(ship, ship_coordinates)
    end

    def firing_phase
    puts "\nWe are ready to RRRRUUUUMMBBBLLLEEE!\n\n"
    until @player.health == 0 || @computer.health == 0 do
      puts "COMPUTER BOARD".center(60, "=")
      puts @computer_board.render
      puts "PLAYER BOARD".center(60, "=")
      puts @player_board.render(true)
      puts "\nEnter the coordinate for your shot:"
      print '> '
      player_target = gets.chomp.to_s.upcase
      if !@computer_board.valid_coordinate?(player_target)
        puts
        puts "Invalid coordinate. What board are you playing on?".center(60, "=")
        puts
        next
      elsif @computer_board.cells[player_target].render != '.'
        puts
        puts "Ha! You already fired there.".center(60, "=")
        puts
      elsif
        @computer_board.cells.include?(player_target)
        @computer_board.cells[player_target].fire_upon
        puts "\nYour #{@computer_board.cells[player_target].shot_result}"
      else
        puts
        puts "Please enter valid coordinate:".center(60, "=")
        puts
      end
      computer_shot = @computer_targets.delete(@computer_targets.sample)
      if @player_board.cells.include?(computer_shot)
        @player_board.cells[computer_shot].fire_upon
        puts "My #{@player_board.cells[computer_shot].shot_result}\n"
        puts
      end
      health_check
    end
    game_over
  end

  def game_over
    puts "COMPUTER BOARD".center(60, "=")
    puts @computer_board.render
    puts "PLAYER BOARD".center(60, "=")
    puts @player_board.render(true)
    if @computer.health == 0
      puts
      puts "PLAYER WINS!".center(60, "*")
      puts
    elsif @player.health == 0
      puts
      puts "COMPUTER WINS!".center(60, "*")
      puts
    end
    play_again
  end

  def play_again
    puts "Enter m to return to main menu or q to quit"
    print '> '
    input = gets.chomp.downcase
    if input == 'm'
      main_menu
    elsif input == 'q'
      exit
    else "I don't recognize that input. Try again."
    end
  end
end
