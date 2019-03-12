# https://www.primarysite-kidszone.co.uk/kidszone/resources/connect4.htm
# Ruby code file - All your code should be located between the comments provided.

# # The files -- 1) 'wad_ms_gen_01.rb', 2) 'wad_ms_run_01.rb', 3) 'wad_ms_spec_01.rb' are provided by Dr. Nigel Beacham"
# The code structure, tests in spec file and instructions to develop game methods and tests are provided by Dr. Nigel Beacham"

# Add any additional gems and global variables here
require 'sinatra'		# character to run sinatra wen server

# Main class module
module MS_Game
	
  # Input and output constants processed by subprocesses. MUST NOT change.
	TOKEN1 = "O" # mine found
	TOKEN2 = "X" # mine not found

	class Game
		attr_reader :matrix, :player1, :player2, :hotspots, :input, :output, :turn, :turnsleft, :winner, :played, :score, :resulta, :resultb, :guess
		attr_writer :matrix, :player1, :player2, :hotspots, :input, :output, :turn, :turnsleft, :winner, :played, :score, :resulta, :resultb, :guess
		
		def initialize(input, output)
			@input = input
			@output = output
            @resulta = resulta
            @resultb = resultb
            @player1 = player1
            @player2 = player2
            @matrix = matrix
            @winner = winner
        end
		
		def getinput
			txt = @input.gets.chomp
			return txt
		end
		
		# Any code/methods aimed at passing the RSpect tests should be added below.
        
        # --- Following methods implemented to check and output the different messages ----
		def start()
            @output.puts "Welcome to Minesweeper!"
            @output.puts "Game started."
            @output.puts "Created by:#{created_by()}"
            @output.puts "Enter a coordinate to uncover if mine found."
        end
        
        def created_by
            myname = "Karthik Karanam"
        end
        
        def student_id
            studentid = 51881492
        end
        
        def displaybegingame
            @output.puts "Begin game."
        end
        
        def displaynewgamecreated	
            @output.puts "New game created."
        end
        
        def finish
            @output.puts "Game finished."
        end
        
        
        # --- Following display methods are implemented to different outputs in the game play process ---
        # --- these methods will be further implemented to capture actual values when the game is running ---
        def displaymenu
            @output.puts "Menu: (1)Start | (2)New | (9)Exit\n"
        end
        
        def clearscores
            @resulta = 0
            @resultb = 0
        end
        
       def displayplayerscores
            clearscores()
            @output.puts "Player 1: 0 and Player 2: 0"
        end
        
        def displayplayer1prompt
            @output.puts "Player 1 to enter coordinate (0 returns to menu)."
        end
        
        def displayplayer2prompt
            @output.puts "Player 2 to enter coordinate (0 returns to menu)."
        end
        
        def displayinvalidinputerror
            @output.puts "Invalid input."
        end
        
        def displaynomoreroomerror
            @output.puts "No more room."
        end
        
        def displaywinner(p)
            @output.puts "Player #{p} wins."
        end
        
        
        
        # --- Methods to set player details and get player details ---
        def setplayer1
            @player1 = TOKEN2
        end
        
        def setplayer2
            @player2 = TOKEN2
        end
        
        def getplayer1
            setplayer1()
        end
        
        def getplayer2
            setplayer2()
        end
        
        
        # --- Defining a 6 X 7 matrix for the game ---
        # --- this method was called multiple times to check each value is "_" or displaying an empty frame ---
        def clearcolumns
                i = 0       # index value
                c = 0       # column value
                v = ""      # Either "X" - TOKEN2 or "O" - TOKEN1
                v1 = ""     # Either "X" - TOKEN2 or "O" - TOKEN1
                v2 = ""     # Either "X" - TOKEN2 or "O" - TOKEN1
                
                @matrix = []
				@matrix[0] = ["_", "_", "_", "_", "_", "_","_"]
				@matrix[1] = ["_", "_", "_", "_", "_", "_","_"]
				@matrix[2] = ["_", "_", "_", "_", "_", "_","_"]
				@matrix[3] = ["_", "_", "_", "_", "_", "_","_"]
				@matrix[4] = ["_", "_", "_", "_", "_", "_","_"]
				@matrix[5] = ["_", "_", "_", "_", "_", "_","_"]
				@matrix[6] = ["_", "_", "_", "_", "_", "_","_"]
                
                @title = "  1 2 3 4 5 6 7 "
				@rowdivider = " +-+-+-+-+-+-+-+"
				@rowAempty = "6|_|_|_|_|_|_|_|"
				@rowBempty = "5|_|_|_|_|_|_|_|"
				@rowCempty = "4|_|_|_|_|_|_|_|"
				@rowDempty = "3|_|_|_|_|_|_|_|"
				@rowEempty = "2|_|_|_|_|_|_|_|"
				@rowFempty = "1|_|_|_|_|_|_|_|"
          end
        
          def getcolumnvalue(c,i)
              clearcolumns()
              @value = @matrix[c][i] 
          end
        
         # --- method to set matrix values to either "X" or "O" (mine not found or mine found) ---
         # --- This method validates 4 tests (#25, #26, #27 #28 tests) from spec file --- 
         # --- algorithmic approach is explained in the manual (Algorithm 1) ---
         def setmatrixcolumnvalue(c, i, v)
            if matrix[c][i] == "_"
            v2 = "O"
            v1 = "X"
                if v == v1
                     v1 = v
                     @matrix[c][i] = v1 # Mine not found
                elsif v == v2
                     v2 = v
                    @matrix[c][i] = v2 # Mine found
                end
             end
         end
        
        
        # --- This method displays an empty frame before a game starts by claiing clearcolumns() method ---
        def displayemptyframe
            clearcolumns()
             @output.puts "#{@title}"
             for i in 1..7   
                 @output.puts "#{@rowdivider}"
             end
             @output.puts "#{@rowAempty}"
             @output.puts "#{@rowBempty}"
             @output.puts "#{@rowCempty}"
             @output.puts "#{@rowDempty}"
             @output.puts "#{@rowEempty}"
             @output.puts "#{@rowFempty}"
		end
            
        # --- method to generate the mines randomly ---   
        # --- algorithmic approach is mentioned in the manual (Algorithm 2)--- 
        def generatemines
            pos = []
            for i in 1..42
                pos << i
            end
           
            # --- Alternative way for checking whether the positions are shuffled or not! --- 
            # --- which can be used for implementation of the game later in assignment 3 ---    
            #     hotspots = pos.shuffle
            #     hotspots.each do |h|
            #        puts h
            #     end
            
            hotspots = []
			for i in 0..41 do
				j = pos.size-1
                r = rand(0..j)
                hotspots.push(pos[r])
				pos.delete_at(r)
				j = j - 1
			end
            @hotspots = hotspots
        end
            
                
        # --- defined a new method to call generatemines method and fetch @hotspots array of values ---
        # --- algorithmic approach is mentioned in the manual (Algorithm 3)---
        def hotspotsvalueckeck
            generatemines
            num = true
				for i in 0..41 
					if @hotspots[i].integer? == false 
						num = false						
					end
				end
            s = @hotspots.size
            u = @hotspots.uniq!
        end
               
      # --- method to check the winner of the game ---
      # --- algorithmic approach is explained in the manual (Algorithm 4)---    
        def checkwinner
            if @resulta == 3 and @resultb == 0
                @winner = 1
            elsif @resultb == 3 and @resulta == 0
                @winner = 2
            else
                @winner = nil
            end
        end
        
       # Any code/methods aimed at passing the RSpect tests should be added above.

	end
end
