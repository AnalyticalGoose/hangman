require_relative "variables.rb"
# require 'json'
# require 'io/console'

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
        sample.length > 5 ? @word = sample.chomp : choose_word
        @hint = "_"*@word.length
        play_game
    end

    def play_game
        draw_game
        check_win
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

        if @guess == "/s"
            save_game
        elsif @guess == "/l"
            load_game
        elsif @guess == @word
            abort "Congratulations, you've guessed the word! \n "
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

    # Checks if the guess is included in the word.
    # Turns the word into an array, counts the occurences of the guessed letter and returns the indexes of the matches
    # loops through the number of matches, slices out the placeholder '_' and inserts the correct letter into the hint.
    # Else the wrong guess is appended the the used letters and the attempt number is incremented

    def update_vars
        if @word.include?(@guess)           
            index = @word.chars.each_index.select {|i| @word[i] == @guess}
            index.length.times do |x = 0|
                @hint.slice!(index[x])
                @hint = @hint.insert index[x], @guess
                x += 1
                end
        else
            @used_letters << @guess
            @attempt += 1
            check_lose
        end
            play_game
    end

    def check_win
        @word == @hint ? abort("Congratulations, you've guessed the word! \n ") : return
    end

    def check_lose
        @attempt >= 7 ? abort("Sorry you've lost! The correct word was #{@word}! \n ") : return
    end

    def save_game   
        File.open('save_game.json', 'w') do |file|
            file.puts(generate_json)
            puts "Game successfully saved! The game will automatically quit"
            abort
        end
    end

    def load_game
        return unless File.exists?('save_game.json')
        File.open('save_game.json', 'r') do |file|
            load_json(file)
        end
    end

    def generate_json
        JSON.dump({
            attempt: @attempt,
            word: @word,
            used_letters: @used_letters,
            hint: @hint,
        })
    end

    def load_json(save_game)
        saved_data = JSON.parse(File.read(save_game))
            @attempt = saved_data['attempt']
            @word = saved_data['word']
            @used_letters = saved_data['used_letters']
            @hint = saved_data['hint']
        puts "Game successfully loaded!"
        play_game
    end
end

game = Game.new.choose_word
