require_relative "variables.rb"

include Variables

class Game
    def initialize
        @attempt = 0
        @word = ""
        @used_letters = ""
        @hint = ""
        @guess = ""
    end

    def choose_word
        sample = File.readlines("words.txt").sample
        sample.length > 5 ? @word = sample : choose_word
        @hint = "_"*@word.chop.length
        puts @word
        play_game
    end

    def play_game
        draw_game
        get_guess
        update_vars
    end

    def draw_game
        puts GAME_DISPLAY[@attempt]
        puts "    Word: [#{@hint}]   Used letters: [#{@used_letters}]\n "
    end

    def get_guess
        puts "Guess a letter! (or the whole word if you're brave!)"
        @guess = gets.downcase.chomp
        
        if @guess == @word
            abort "Winner!"
        elsif @guess !~ (/[a-zA-Z]/) || @guess.length > 1 && @guess.length < @word.length
            puts "Invalid character"
            get_guess
        elsif @used_letters.include?(@guess) || @hint.include?(@guess)
            puts "Letter already chosen!"
            get_guess
        else
            return
        end
    end

    def update_vars
        if @word.include?(@guess)
            index = @word.index(@guess)
            @hint.slice!(index)
            @hint = @hint.insert index, @guess
        end
        play_game
    end
end

game = Game.new.choose_word
