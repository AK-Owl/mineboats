# Ruby code file - All your code should be located between the comments provided.
# The run, spec and gen files for the game were provided by Dr Nigel Beacham.
# Add any additional gems and global variables here

require 'sinatra'		
require 'sinatra/activerecord'

$myname = "Mystified Squad"

ActiveRecord::Base.establish_connection(
    :adapter=>'sqlite3',
    :database=>'minesweeper.db')

ActiveRecord::Base.logger.level = 1

class Users<ActiveRecord::Base
    validates :playername, presence:true, uniqueness:true
    validates :gamesplayed, presence:true
    validates :gameswon, presence:true
end

class Loggedusers<ActiveRecord::Base
    validates :username, presence:true, uniqueness:true
    validates :password, presence:true
end

class Gamestatuses<ActiveRecord::Base
	validates :saveslot, presence:true
	validates :player1, presence:true
	validates :player2, presence:true
	validates :p1score, presence:true
	validates :p2score, presence:true
    validates :playerturn, presence:false
	validates :matrix0, presence:false
	validates :matrix1, presence:false
	validates :matrix2, presence:false
	validates :matrix3, presence:false
	validates :matrix4, presence:false
	validates :matrix5, presence:false
	validates :board0, presence:false
	validates :board1, presence:false
	validates :board2, presence:false
	validates :board3, presence:false
	validates :board4, presence:false
	validates :board5, presence:false
end

# Main class module
module MS_Game
	# Input and output constants processed by subprocesses. MUST NOT change.
	TOKEN1 = "O" # mine found
	TOKEN2 = "X" # mine not found

	class Game
		attr_reader :matrix, :player1, :player2, :hotspots, :input, :output, :turn, :turnsleft, :winner, :played, :score, :resulta, :resultb, :guess
		attr_writer :matrix, :player1, :player2, :hotspots, :input, :output, :turn, :turnsleft, :winner, :played, :score, :resulta, :resultb, :guess
		
            def protected!
                if authorized?
                    return
                end
                redirect '/denied'
            end

            def authorized?
                if $credentials != nil
                    @User = Loggedusers.where(:username => $credentials[0]).to_a.first
                    if @User
                        if @User.edit == true
                            return true
                        else
                            return false
                        end
                    else
                        return false
                    end
                end
            end        
        
		def initialize(input, output)
			@input = input
			@output = output
		end
		
		def getinput
			txt = @input.gets.chomp
			return txt
		end
		
		# Any code/methods aimed at passing the RSpect tests should be added below.
        # displays messages at the start of the game
		def start
            @output.puts (" \u001b[36mWelcome to Minesweeper!\u001b[0m")
            @output.puts (" Created by: #{$myname}")
            @output.puts (" Game started...")
            @output.puts (" Enter a coordinate to uncover if mine found.")
        end
        
        def displaybegingame
            @output.puts ("\n\u001b[34mBegin game..\u001b[0m")
        end
        
        def displaynewgamecreated
            @output.puts ("\n\u001b[34mNew game created..\u001b[0m")
        end
        
        def finish
            @output.puts ("\n\u001b[34mGame finished..\u001b[0m")
        end
        
        def displaymenu 
            @output.puts (" \u001b[31mMenu: \u001b[37m(1)\u001b[0m \u001b[31mNew Game | \u001b[37m(2)\u001b[0m \u001b[31mLoad Game | \u001b[37m(3)\u001b[0m \u001b[31m Leaderboard | \u001b[37m(9)\u001b[0m \u001b[31mExit\u001b[0m")
        end
        # resets the scores
        def clearscores
            $resulta=0
            $resultb=0
        end
        
        def displayplayerscores
            @output.puts ("\u001b[36m##{$player1name}:\u001b[0m 0 and \u001b[32m#{$player2name}:\u001b[0m 0")
        end
        
        def displayplayer1prompt 
            @output.puts ("\u001b[36m#{$player1name}\u001b[0m to enter coordinate (Type \u001b[36m\'save\'\u001b[0m to save the game or type \u001b[36m\'exit\'\u001b[0m to return to the menu).")
        end
        
        def displayplayer2prompt
            @output.puts ("\u001b[32m#{$player2name}\u001b[0m to enter coordinate (Type \u001b[36m\'save\'\u001b[0m to save the game or type \u001b[36m\'exit\'\u001b[0m to return to the menu).")
        end
        
        def displayinvalidinputerror
            @output.puts ("\u001b[31mInvalid input. Please refer to the grid for row and column values.\u001b[0m")
        end
        
        def displaynomoreroomerror
            @output.puts ("No more room.")
        end
        #the two following methods display the winner and store the values into db     
        def displaywinner(p)
            if    p == 1
                    @output.puts ("\u001b[36m#{$player1name}\u001b[0m WON!!!")
                    a = Users.all
                    a.each do |b|
                        if  b.playername == $player1name
                            b.gamesplayed = b.gamesplayed
                            b.gameswon+=1
                            b.save
                        end
                    end
             elsif p == 2
                    @output.puts ("\u001b[32m#{$player2name}\u001b[0m WON!!")
                    a = Users.all
                    a.each do |b|
                        if b.playername == $player2name
                           b.gamesplayed = b.gamesplayed
                           b.gameswon+=1
                           b.save
                        end
                    end
             end
             $playing = false
        end
        
        def displaywebwinner(p)
            
            if    p == 1
                  $player = $log_username
                    a = Users.all
                    a.each do |b|
                        if  b.playername == $log_username
                            b.gamesplayed = b.gamesplayed
                            b.gameswon+=1
                            b.save
                        end
                    end
             elsif p == 2
                $player = $opponent
                    a = Users.all
                    a.each do |b|
                        if b.playername == $opponent
                           b.gamesplayed = b.gamesplayed
                           b.gameswon+=1
                           b.save
                        end
                    end
             end
            $playing = false
        end
        
        #initialise players
        def setplayer1
            @output.puts "\n\u001b[36mPlayer 1 please enter your name.\u001b[0m"
            $player1name = @input.gets.chomp.to_s
            users = Users.all
            users.each do |u|
                if u.playername == $player1name
                   u.gamesplayed+= 1
                   u.save
                else
                n = Users.new
                n.playername = $player1name
                n.gamesplayed = 1
                n.gameswon = 0
                n.save
                end
            end
        end
        
        def setplayer2
            @output.puts "\n\u001b[32mPlayer 2 please enter your name.\u001b[0m"
            $player2name=@input.gets.chomp.to_s
            users = Users.all
            users.each do |u|
                if u.playername == $player2name
                   u.gamesplayed+=1 
                   u.save
                else
                n = Users.new
                n.playername = $player2name
                n.gamesplayed = 1
                n.gameswon = 0
                n.save
                end
            end
        end
        
        def setopponent(opponent)
            users = Users.all
            users.each do |u|
                if u.playername == opponent
                   u.gamesplayed+=1 
                   u.save
                else
                n = Users.new
                n.playername = opponent
                n.gamesplayed = 1
                n.gameswon = 0
                n.save
                end
            end
        end
        
        # clears the game matrix
        def clearcolumns
            $matrix = []
            for i in 0..5 do
                $matrix[i] = ["_", "_", "_", "_", "_", "_", "_"]
            end
        end
        
        # finds values for target cell on the board
        def getcolumnvalue(row, column)
            @selectedcolumn = $matrix[row][column]
        end
       
        # place mine tokens (mine/no mine)
        def setmatrixcolumnvalue(c, i)
            if $matrix [c][i] == "X" || $matrix [c][i]=="O"
                @output.puts "\n\u001b[31mThis field has already been uncovered. Please try another one.\u001b[31m"
            else
                if $matrix[c][i] == "*"  
                    if $turn == "P1"
                        $resulta += 1
                        @output.puts "\n\u001b[36m#{$player1name}\u001b[0m hits a mine... Current score is - \u001b[36m#{$player1name}\u001b[0m: #{$resulta}; \u001b[32m#{$player2name}\u001b[0m: #{$resultb}."
                    elsif $turn == "P2"
                        $resultb += 1
                        @output.puts "\n\u001b[32m#{$player2name}\u001b[0m hits a mine... Current score is - \u001b[36m##{$player1name}:\u001b[0m: #{$resulta}; \u001b[32m#{$player2name}\u001b[0m: #{$resultb}."
                    end
                    $matrix[c][i] = "O"
                    $board[c][i]= "O"
                else
                    $matrix[c][i] = "X"
                    $board[c][i]= "X"
                    if $turn == "P1"
                        @output.puts "\n\u001b[36m#{$player1name}\u001b[0m misses a mine... Current score is - \u001b[36m#{$player1name}\u001b[0m: #{$resulta}; \u001b[32m#{$player2name}\u001b[0m: #{$resultb}."
                    elsif $turn == "P2"
                        @output.puts "\n\u001b[32m#{$player2name}\u001b[0m misses a mine... Current score is - \u001b[36m#{$player1name}\u001b[0m: #{$resulta}; \u001b[32m#{$player2name}\u001b[0m: #{$resultb}."
                    end
                end
            end
        end
        
        # displays the board
        def displayemptyframe
            @gametitle =  "\n\u001b[33mM I N E S W E E P E R\u001b[0m"
            @title = "\n\u001b[34m   1 2 3 4 5 6 7 "
            @rowAempty = " 1|_|_|_|_|_|_|_|"
            @rowBempty = " 2|_|_|_|_|_|_|_|"
            @rowCempty = " 3|_|_|_|_|_|_|_|"
            @rowDempty = " 4|_|_|_|_|_|_|_|"
            @rowEempty = " 5|_|_|_|_|_|_|_|"
            @rowFempty = " 6|_|_|_|_|_|_|_|"
         
            @output.puts ("#{@gametitle}")
            @output.puts ("#{@title}")
            
            @output.puts ("#{@rowAempty}")
			@output.puts ("#{@rowBempty}")
			@output.puts ("#{@rowCempty}")
			@output.puts ("#{@rowDempty}")
			@output.puts ("#{@rowEempty}")
			@output.puts ("#{@rowFempty}")  
            @output.puts ("\u001b[0m")
        end
        
        # assigns mines to random cells on the board
        def generatemines
            pos = []
            for i in 1..42 do
                pos << i
            end
			hotspots = []
                for i in 0..41 do
                    j = pos.size-1
                    r = rand(0..j)
                    hotspots.push(pos[r])
                    pos.delete_at(r)
                    j = j - 1
                end
			$hotspots = hotspots
            for i in 0..5 do
            $hotspots[i] = "*"
            end   
            $hotspots = $hotspots.shuffle
        end
        
        def assignmines
            $matrix[0]=$hotspots[0..6]
            $matrix[1]=$hotspots[7..13]
            $matrix[2]=$hotspots[14..20]
            $matrix[3]=$hotspots[21..27]
            $matrix[4]=$hotspots[28..34]
            $matrix[5]=$hotspots[35..41]
        end
        
        def updatematrix
            @title = "  1 2 3 4 5 6 7 "
            $rowA = $matrix[0]
            $rowB = $matrix[1]
            $rowC = $matrix[2]
            $rowD = $matrix[3]
            $rowE = $matrix[4]
            $rowF = $matrix[5]
            
            $rowAsave = $matrix[0].join('|')
            $rowBsave = $matrix[1].join('|')
            $rowCsave = $matrix[2].join('|')
            $rowDsave = $matrix[3].join('|')
            $rowEsave = $matrix[4].join('|')
            $rowFsave = $matrix[5].join('|')
            
        #for Debugging the matrix values            
            #@output.puts ("#{@title}")
            #@output.puts ("#{$rowA}")
			#@output.puts ("#{$rowB}")
			#@output.puts ("#{$rowC}")
			#@output.puts ("#{$rowD}")
			#@output.puts ("#{$rowE}")
			#@output.puts ("#{$rowF}")  
        end
        
        def checkwinner
            if $resultb == 3
                $winner = 2
            elsif $resulta == 3
                $winner = 1
            else
                $winner= nil
            end
            if $winner != nil
                displaywinner($winner)
            end
        end
        
        def checkwebwinner
            if $resultb == 3
                $winner=2
                $playing == true
            elsif $resulta == 3
                $winner=1
                $playing == true
            else
                $winner= nil
            end
            if $winner != nil
                displaywebwinner($winner)
            end
        end
        
        #creates empty gameboard
        def createboard
          $board=[]
            for i in 0..5 do
                $board[i] = ["_","_","_","_","_","_","_"] 
            end
        end
     
        def displayboard
            @gametitle =  "\n\u001b[33mM I N E B O A T S\u001b[0m"
            $boardtitle = "\n   1 2 3 4 5 6 7 \u001b[34m"
            $rowAb = $board[0].join('|')
            $rowBb = $board[1].join('|')
            $rowCb = $board[2].join('|')
            $rowDb = $board[3].join('|')
            $rowEb = $board[4].join('|')
            $rowFb = $board[5].join('|')
            
            @output.puts ("#{@gametitle}") 
            @output.puts ("#{$boardtitle}")
            
            @output.puts (" 1|"+"#{$rowAb}"+"|")
			@output.puts (" 2|"+"#{$rowBb}"+ "|")
			@output.puts (" 3|"+"#{$rowCb}"+ "|")
			@output.puts (" 4|"+"#{$rowDb}"+ "|")
			@output.puts (" 5|"+"#{$rowEb}"+ "|")
			@output.puts (" 6|"+"#{$rowFb}"+ "|")  
            @output.puts ("\u001b[0m")
        end
        
        def savegame
            $games = Gamestatuses.count
            x = Gamestatuses.new
            x.saveslot = $games +1
            x.player1 = $player1name
            x.player2 = $player2name
            
            x.p1score = $resulta
            x.p2score = $resultb
            
            x.playerturn = $turn
            
            x.matrix0 = $rowAsave
            x.matrix1 = $rowBsave
            x.matrix2 = $rowCsave
            x.matrix3 = $rowDsave
            x.matrix4 = $rowEsave
            x.matrix5 = $rowFsave
            
            x.board0 = $rowAb
            x.board1 = $rowBb
            x.board2 = $rowCb
            x.board3 = $rowDb
            x.board4 = $rowEb
            x.board5 = $rowFb
            
            x.save 
            displayboard
        end
         
        def loadgame
            $games = Gamestatuses.all.sort_by {|g| [g.saveslot]}
            $games.each do |games|
                @output.puts ("Game " + "#{games.saveslot}" + " | " + "#{games.player1}" + " vs " + "#{games.player2}")
            end
            @output.puts "\u001b[36mPlease enter a number to load the game...\u001b[0m"
            gameinput = gets.chomp.to_i
            $games.each do |lg|
                if gameinput == lg.saveslot
                    $player1name = lg.player1
                    $log_username = lg.player1
                    
                    $player2name = lg.player2
                    $opponent = lg.player2
                    
                    $resulta = lg.p1score
                    $resultb = lg.p2score
                    
                    $turn = lg.playerturn
                    
                    $rowA = lg.matrix0
                    $rowB = lg.matrix1
                    $rowC = lg.matrix2
                    $rowD = lg.matrix3
                    $rowE = lg.matrix4
                    $rowF = lg.matrix5
                    
                    $matrix = []
                    $matrix[0] = $rowA.split('|')
                    $matrix[1] = $rowB.split('|')
                    $matrix[2] = $rowC.split('|')
                    $matrix[3] = $rowD.split('|')
                    $matrix[4] = $rowE.split('|')
                    $matrix[5] = $rowF.split('|')
                    
                    $rowAb = lg.board0
                    $rowBb = lg.board1
                    $rowCb = lg.board2
                    $rowDb = lg.board3
                    $rowEb = lg.board4
                    $rowFb = lg.board5
                    
                    $board = []
                    $board[0] = $rowAb.split('|')
                    $board[1] = $rowBb.split('|')
                    $board[2] = $rowCb.split('|')
                    $board[3] = $rowDb.split('|')
                    $board[4] = $rowEb.split('|')
                    $board[5] = $rowFb.split('|')
                    updatematrix
                 end
            end
        end
        
        def loadwebgame(l)
            $games = Gamestatuses.all.sort_by {|g| [g.saveslot]}
            $games.each do |lg|
                if lg.saveslot == l.to_i
                    $player1name = lg.player1
                    $log_username = lg.player1
                    
                    $player2name = lg.player2
                    $opponent = lg.player2
                    
                    $resulta = lg.p1score
                    $resultb = lg.p2score
                    
                    $turn = lg.playerturn
                    
                    $rowA = lg.matrix0
                    $rowB = lg.matrix1
                    $rowC = lg.matrix2
                    $rowD = lg.matrix3
                    $rowE = lg.matrix4
                    $rowF = lg.matrix5
                    
                    $matrix = []
                    $matrix[0] = $rowA.split('|')
                    $matrix[1] = $rowB.split('|')
                    $matrix[2] = $rowC.split('|')
                    $matrix[3] = $rowD.split('|')
                    $matrix[4] = $rowE.split('|')
                    $matrix[5] = $rowF.split('|')
                    
                    $rowAb = lg.board0
                    $rowBb = lg.board1
                    $rowCb = lg.board2
                    $rowDb = lg.board3
                    $rowEb = lg.board4
                    $rowFb = lg.board5
                    
                    $board = []
                    $board[0] = $rowAb.split('|')
                    $board[1] = $rowBb.split('|')
                    $board[2] = $rowCb.split('|')
                    $board[3] = $rowDb.split('|')
                    $board[4] = $rowEb.split('|')
                    $board[5] = $rowFb.split('|')       
                 end
            end
        end
        
        def leaderboard
                @output.puts ("\u001b[36mName---Games Played -- Games Won\u001b[0m")
                n = Users.all.sort_by {|g| [g.gameswon]}
                n.each do |t|
                    @output.puts ("Name: " + "#{t.playername}" + "Games Played: " +  "#{t.gamesplayed}" + "Games Won: " + "#{t.gameswon}")
                end
           end
		# Any code/methods aimed at passing the RSpect tests should be added above.
    end
end